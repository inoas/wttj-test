defmodule WttjWeb.JobController do
  use WttjWeb, :controller

  alias Wttj.Jobs
  alias Wttj.Jobs.Job

  alias Wttj.Professions

  def index(conn, _params) do
    jobs = Jobs.list_jobs_with_profession()
    render(conn, "index.html", jobs: jobs)
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
end
