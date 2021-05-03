defmodule WttjWeb.JobApiView do
  use WttjWeb, :view
  alias WttjWeb.JobApiView

  def render("index.json", %{jobs: jobs}) do
    %{data: render_many(jobs, JobApiView, "job_api.json")}
  end

  def render("show.json", %{job_api: job_api}) do
    %{data: render_one(job_api, JobApiView, "job_api.json")}
  end

  def render("job_api.json", %{job_api: job_api}) do
    %{
			id: job_api.id,
			name: job_api.name,
			contract_type: job_api.contract_type,
			country_name: job_api.countries.name,
			continent_name: job_api.countries.continent_name,
			profession_name: job_api.professions.name,
			profession_category_name: job_api.professions.category_name,
			office_location_latitude: (if job_api.office_location != nil, do: elem(job_api.office_location.coordinates, 0), else: nil ),
			office_location_longitude: (if job_api.office_location != nil, do: elem(job_api.office_location.coordinates, 1), else: nil )
		}
  end
end
