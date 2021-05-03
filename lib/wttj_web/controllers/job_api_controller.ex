defmodule WttjWeb.JobApiController do
  use WttjWeb, :controller

  alias Wttj.Api

  action_fallback WttjWeb.FallbackController

  # Call like so: http://localhost:4000/api/jobs?latitude=44&longitude=8&radius_in_km=100
  def index(conn, params) do
    params =
      if Map.has_key?(params, "radius_in_km"),
        do: params,
        else: params |> Map.put("radius_in_km", "50")

    jobs =
      with false <- params["latitude"] == nil,
           {latitude, _} <- Float.parse(params["latitude"]),
           false <- params["longitude"] == nil,
           {longitude, _} <- Float.parse(params["longitude"]),
           false <- params["radius_in_km"] == nil,
           {radius_in_km, _} <- Float.parse(params["radius_in_km"]) do
        Api.find_job_by_coords_in_radius_in_km(%{
          "latitude" => latitude,
          "longitude" => longitude,
          "radius_in_km" => radius_in_km
        })
      else
        _ -> []
      end

    render(conn, "index.json", jobs: jobs)
  end

  # Call like: http://localhost:4000/api/jobs/1
  def show(conn, %{"id" => id}) do
    job = Api.find_job(id)
    render(conn, "show.json", job_api: job)
  end
end
