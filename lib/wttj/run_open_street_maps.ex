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

  @job_interval_in_milli_seconds 50
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
    IO.inspect("Fetching geo data from open street maps API...")

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

  # def request_open_street_maps_data_and_update_record(device) do
  #   %Devices.DeviceHistory{object_photo_binary: object_photo_binary} = device

  #   if object_photo_binary != nil do
  #     %Devices.DeviceHistory{id: device_history_id} = device

  #     with {:ok, open_street_maps_api_responses} <-
  #            fetch_open_street_maps_api_data_coords(object_photo_binary),
  #          {:ok, open_street_maps_api_responses} <-
  #            open_street_maps_api_responses |> Map.fetch("responses"),
  #          {:ok, open_street_maps_api_responses} <-
  #            open_street_maps_api_responses
  #            |> List.first()
  #            |> Map.fetch("localizedObjectAnnotations"),
  #          {:ok, open_street_maps_api_responses} <-
  #            open_street_maps_api_responses
  #            |> Jason.encode() do
  #       DevicesHistory.atomic_update_open_street_maps_api_result_if_nil(
  #         device_history_id,
  #         open_street_maps_api_responses
  #       )
  #     else
  #       _error ->
  #         {:ok, open_street_maps_api_responses} =
  #           %{"googleVisionApiReturnedNoLocalizedObjectAnnotations" => true}
  #           |> Jason.encode()

  #         DevicesHistory.atomic_update_open_street_maps_api_result_if_nil(
  #           device_history_id,
  #           open_street_maps_api_responses
  #         )
  #     end
  #   end
  # end

  # defp fetch_open_street_maps_api_data_coords(image_binary) do
  #   image_binary_base_64_encoded = Base.encode64(image_binary)

  #   {:ok, json_post_body} =
  #     Jason.encode(%{
  #       "requests" => [
  #         %{
  #           "features" => [
  #             %{
  #               "type" => "OBJECT_LOCALIZATION",
  #               "maxResults" => 10
  #             }
  #           ],
  #           "image" => %{
  #             "content" => image_binary_base_64_encoded
  #           }
  #         }
  #       ]
  #     })

  #   # Goth.Token.for_scope will reuse existing tokens
  #   {:ok, %Goth.Token{token: google_cloud_platform_bearer_token}} =
  #     Goth.Token.for_scope("https://www.googleapis.com/auth/cloud-platform")

  #   url = "https://vision.googleapis.com/v1/images:annotate"

  #   headers = [
  #     {"Cache-Control", "private"},
  #     {"Content-Type", "application/json; charset=utf-8"},
  #     {"Accepts", "application/json; charset=utf-8"},
  #     {"Authorization", "Bearer #{google_cloud_platform_bearer_token}"}
  #   ]

  #   IO.inspect("Calling " <> url)

  #   options = [ssl: [{:versions, [:"tlsv1.2"]}], recv_timeout: 10_000]

  #   case HTTPoison.post(url, json_post_body, headers, options) do
  #     {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
  #       Jason.decode(body)

  #     {:ok, %HTTPoison.Response{status_code: 401}} ->
  #       {:error, "authentication with remote webservice failed!"}

  #     {:ok, %HTTPoison.Response{status_code: 404}} ->
  #       {:error, "remote webservice could not find requested document"}

  #     {:error, %HTTPoison.Error{reason: reason}} ->
  #       {:error, reason}
  #   end
  # end
end
