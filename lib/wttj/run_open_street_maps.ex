defmodule Wttj.RunOpenStreetMaps do
  @moduledoc """
  1. Loops through device / device_history database
  2. Finds records with binary data but without google vision data (null)
  3. Pushes image binary data to google
  4. Retreive google vision api result
  5. Stores google vision api result with image
  """
  use GenServer
  alias Wttj.Jobs
  alias Wttj.Countries

  @job_interval_in_milli_seconds 25
  @max_concurrent_http_requests 2

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Process.send_after(self(), :work, 100)
    {:ok, %{last_run_at: nil}}
  end

  def handle_info(:work, _state) do
    process_jobs_without_geo_data()
    Process.send_after(self(), :work, @job_interval_in_milli_seconds)
    # By storing last_run_at in state we get basic monitoring via process inspection.
    # It's just for convenience - don't use this technique for sophisticated instrumentation of your processes.
    {:noreply, %{last_run_at: :calendar.local_time()}}
  end

  defp process_jobs_without_geo_data do
    Jobs.list_jobs_with_office_location_and_missing_geo_data(@max_concurrent_http_requests)
    |> Task.async_stream(fn items -> request_open_street_maps_data_and_update_record(items) end,
      max_concurrent_http_requests: @max_concurrent_http_requests
    )
    |> Stream.run()
  end

  def request_open_street_maps_data_and_update_record(job) do
    with {:ok, open_street_maps_api_responses} <- fetch_open_street_maps_api_data_coords(job),
         {:ok, address} <- open_street_maps_api_responses |> Map.fetch("address"),
         {:ok, country_code} <- address |> Map.fetch("country_code"),
         {:ok, country_id} <- Countries.find_country_id_by_code(country_code) do
      Jobs.update_job_with_geo_data(job, country_id)
    else
      _error ->
        IO.inspect("Could not update record via open street maps API")
        {:error, "nopes"}
    end
  end

  def fetch_open_street_maps_api_data_coords(job) do
    base_url =
      "https://nominatim.openstreetmap.org/reverse?format=json&lat={LATITUDE}&lon={LONGITUDE}"

    headers = [
      {"Cache-Control", "private"},
      {"Content-Type", "application/json; charset=utf-8"},
      {"Accepts", "application/json; charset=utf-8"}
    ]

    url =
      base_url
      |> String.replace(
        "{LATITUDE}",
        elem(job.office_location.coordinates, 0) |> Float.to_string()
      )
      |> String.replace(
        "{LONGITUDE}",
        elem(job.office_location.coordinates, 1) |> Float.to_string()
      )

    IO.inspect("Calling " <> url)

    options = [ssl: [{:versions, [:"tlsv1.2"]}], recv_timeout: 10_000]

    case HTTPoison.get(url, headers, options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Jason.decode(body)

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
