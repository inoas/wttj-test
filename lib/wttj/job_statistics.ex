defmodule Wttj.JobStatistics do
  @moduledoc """
  The JobStatistics context.
  """

  import Ecto.Query, warn: false
  alias Wttj.Repo

  alias Wttj.Jobs.Job
  alias Wttj.Countries.Country
  alias Wttj.Professions.Profession

  @doc """
  Returns job statistics.

  Implement:

  ```sql
  SELECT
   c0.continent_name,
   count(j0.id) as jobs_count
  FROM jobs AS j0
  INNER JOIN countries AS c0 ON c0.id = j0.country_id
  GROUP BY c0.continent_name
  ORDER BY jobs_count DESC;
  ```

  """
  def job_statistics_query do
    from(j in Job,
      inner_join: c in Country,
      on: j.country_id == c.id,
      select: %{
        continent_name: c.continent_name,
        job_count: fragment("count(?) as job_count", j.id)
      },
      group_by: [c.continent_name],
      order_by: fragment("job_count DESC")
    )
  end

  def job_statistics_per_profession_query(profession_id) do
    from(
      j in job_statistics_query(),
      inner_join: p in Profession,
      on: j.profession_id == p.id,
      where: p.id == ^profession_id
    )
  end

  def all(query) do
    Repo.all(query)
  end
end
