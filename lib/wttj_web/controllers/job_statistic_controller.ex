defmodule WttjWeb.JobStatisticController do
  use WttjWeb, :controller

  alias Wttj.JobStatistics
  alias Wttj.Professions

  @spec index(Plug.Conn.t(), any) :: Plug.Conn.t()

  def index(conn, %{"profession_id" => ""}) do
    index(conn, %{})
  end

  def index(conn, %{"profession_id" => profession_id}) when is_binary(profession_id) do
    professions = Professions.list_professions()

    job_statistics =
      with {profession_id, _decimals} <- Integer.parse(profession_id),
           profession <- Enum.find(professions, fn map -> map.id == profession_id end) do
        if profession == nil do
          nil
        else
          %{
            profession: profession,
            data:
              JobStatistics.job_statistics_per_profession_query(profession_id)
              |> JobStatistics.all()
          }
        end
      else
        _ -> nil
      end

    render(conn, "index.html", professions: professions, job_statistics: job_statistics)
  end

  def index(conn, _params) do
    professions = Professions.list_professions()

    job_statistics = %{
      profession: nil,
      data: JobStatistics.job_statistics_query() |> JobStatistics.all()
    }

    render(conn, "index.html", professions: professions, job_statistics: job_statistics)
  end
end
