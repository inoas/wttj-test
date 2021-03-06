defmodule WttjWeb.JobController do
  use WttjWeb, :controller

  alias Wttj.Jobs
  alias Wttj.Jobs.Job

  alias Wttj.Professions

  def index(conn, params) do
    pagination = Jobs.paginate_jobs_with_profession(params)

    render(conn, "index.html",
      jobs: pagination.entries,
      pagination: pagination
    )
  end

  def new(conn, _params) do
    professions = Professions.list_professions()
    contract_type_enum_values = Ecto.Enum.values(Wttj.Jobs.Job, :contract_type)
    changeset = Jobs.change_job(%Job{})

    render(conn, "new.html",
      changeset: changeset,
      professions: professions,
      contract_type_enum_values: contract_type_enum_values
    )
  end

  def create(conn, %{"job" => job_params}) do
    case Jobs.create_job(job_params) do
      {:ok, job} ->
        conn
        |> put_flash(:info, "Job created successfully.")
        |> redirect(to: Routes.job_path(conn, :show, job))

      {:error, %Ecto.Changeset{} = changeset} ->
        professions = Professions.list_professions()
        contract_type_enum_values = Ecto.Enum.values(Wttj.Jobs.Job, :contract_type)

        render(conn, "new.html",
          changeset: changeset,
          professions: professions,
          contract_type_enum_values: contract_type_enum_values
        )
    end
  end

  def show(conn, %{"id" => id}) do
    job = Jobs.get_job_with_profession!(id)
    render(conn, "show.html", job: job)
  end

  def edit(conn, %{"id" => id}) do
    professions = Professions.list_professions()
    contract_type_enum_values = Ecto.Enum.values(Wttj.Jobs.Job, :contract_type)
    job = Jobs.get_job!(id)
    changeset = Jobs.change_job(job)

    render(conn, "edit.html",
      job: job,
      changeset: changeset,
      professions: professions,
      contract_type_enum_values: contract_type_enum_values
    )
  end

  def update(conn, %{"id" => id, "job" => job_params}) do
    job = Jobs.get_job!(id)

    case Jobs.update_job(job, job_params) do
      {:ok, job} ->
        conn
        |> put_flash(:info, "Job updated successfully.")
        |> redirect(to: Routes.job_path(conn, :show, job))

      {:error, %Ecto.Changeset{} = changeset} ->
        professions = Professions.list_professions()
        contract_type_enum_values = Ecto.Enum.values(Wttj.Jobs.Job, :contract_type)

        render(conn, "edit.html",
          job: job,
          changeset: changeset,
          professions: professions,
          contract_type_enum_values: contract_type_enum_values
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    job = Jobs.get_job!(id)
    {:ok, _job} = Jobs.delete_job(job)

    conn
    |> put_flash(:info, "Job deleted successfully.")
    |> redirect(to: Routes.job_path(conn, :index))
  end

  def import(conn, _params) do
    render(conn, "import.html")
  end

  def save_import(conn, params) do
    with %Plug.Upload{} = upload <- Map.get(params, "upload"),
         %{content_type: "text/csv"} <- upload,
         {:ok, _imports} <- Jobs.import(upload) do
      conn
      |> put_flash(:info, "Import successful.")
      |> redirect(to: Routes.job_path(conn, :index))
    else
      _ ->
        conn
        |> put_flash(:error, "Import failed: Upload invalid!")
        |> redirect(to: Routes.job_path(conn, :import))
    end
  end

  def finder(conn, params) do
    params =
      if Map.has_key?(params, "radius_in_km"),
        do: params,
        else: params |> Map.put("radius_in_km", "50")

    pagination =
      with false <- params["latitude"] == nil,
           {latitude, _} <- Float.parse(params["latitude"]),
           false <- params["longitude"] == nil,
           {longitude, _} <- Float.parse(params["longitude"]),
           false <- params["radius_in_km"] == nil,
           {radius_in_km, _} <- Float.parse(params["radius_in_km"]) do
        Jobs.find_by_coords_in_radius_in_km_paginated(
          %{
            "latitude" => latitude,
            "longitude" => longitude,
            "radius_in_km" => radius_in_km
          },
          params
        )
      else
        _ -> Jobs.paginate_jobs_with_profession(params)
      end

    render(conn, "finder.html",
      params: params,
      jobs: pagination.entries,
      pagination: pagination
    )
  end
end
