defmodule Wttj.Api do
  @moduledoc """
  The Api context.
  """

  import Ecto.Query, warn: false

  alias Wttj.Repo
  alias Wttj.Jobs

  def find_job_by_coords_in_radius_in_km(params),
    do: Jobs.find_by_coords_in_radius_in_km_query(params) |> limit(1000) |> Repo.all()

  def find_job(job_id),
    do: Jobs.get_job_with_profession!(job_id)
end
