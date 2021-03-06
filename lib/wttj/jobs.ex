defmodule Wttj.Jobs do
  @moduledoc """
  The Jobs context.
  """

  import Ecto.Query, warn: false
  import Geo.PostGIS

  alias Wttj.Repo
  alias Wttj.Jobs.Job
  alias NimbleCSV.RFC4180, as: CSV

  @doc """
  Returns the list of jobs.

  ## Examples

      iex> list_jobs()
      [%Job{}, ...]

  """
  def list_jobs do
    Repo.all(Job)
  end

  @doc """
  Returns the list of jobs.

  ## Examples

      iex> list_jobs()
      [%Job{}, ...]

  """
  def list_jobs_with_office_location_and_missing_geo_data(limit) do
    query =
      from(j in Job,
        where:
          not is_nil(j.office_location) and
            is_nil(j.fetched_country_data_last_datetime),
        order_by: fragment("random()"),
        limit: ^limit
      )

    IO.inspect(
      {"jobs without open street maps geo data:",
       Repo.one(from query, select: fragment("count(*)"))}
    )

    query |> Repo.all()
  end

  @doc """
  Returns a pagination of jobs with associated profession (belongs_to).

  ## Examples

      iex> paginate_jobs_with_profession()
      [%Job{}, ...]

  """
  def paginate_jobs_with_profession(params) do
    Job
    |> preload(:professions)
    |> preload(:countries)
    |> Repo.paginate(params)
  end

  @doc """
  Gets a single job.

  Raises `Ecto.NoResultsError` if the Job does not exist.

  ## Examples

      iex> get_job!(123)
      %Job{}

      iex> get_job!(456)
      ** (Ecto.NoResultsError)

  """
  def get_job!(id), do: Repo.get!(Job, id)

  @doc """
  Gets a single job with associated profession (belongs_to).

  Raises `Ecto.NoResultsError` if the Job does not exist.

  ## Examples

      iex> get_job!(123)
      %Job{}

      iex> get_job!(456)
      ** (Ecto.NoResultsError)

  """
  def get_job_with_profession!(id) do
    Repo.get!(Job, id)
    |> Repo.preload([
      :countries,
      :professions,
      professions: :categories
    ])
  end

  @doc """
  Creates a job.

  ## Examples

      iex> create_job(%{field: value})
      {:ok, %Job{}}

      iex> create_job(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_job(attrs \\ %{}) do
    attrs = attrs |> convert_office_location_attrs()

    %Job{}
    |> Job.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a job.

  ## Examples

      iex> update_job(job, %{field: new_value})
      {:ok, %Job{}}

      iex> update_job(job, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_job(%Job{} = job, attrs) do
    attrs = attrs |> convert_office_location_attrs()

    job
    |> Job.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a job.

  ## Examples

      iex> delete_job(job)
      {:ok, %Job{}}

      iex> delete_job(job)
      {:error, %Ecto.Changeset{}}

  """
  def delete_job(%Job{} = job) do
    Repo.delete(job)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking job changes.

  ## Examples

      iex> change_job(job)
      %Ecto.Changeset{data: %Job{}}

  """
  def change_job(%Job{} = job, attrs \\ %{}) do
    Job.changeset(job, attrs)
  end

  # FIXME: custom Ecto.Type and defimpl Phoenix.HTML.Safe / to_iodata
  defp convert_office_location_attrs(attrs) do
    if Map.has_key?(attrs, "office_latitude") and
         is_numeric(attrs["office_latitude"]) and
         Map.has_key?(attrs, "office_longitude") and
         is_numeric(attrs["office_longitude"]),
       # TODO: FIXME: Confirm this https://stackoverflow.com/questions/36514093/how-do-i-make-a-st-distance-query-in-meters-with-two-elixir-geo-point-locations#comment60680675_36514093
       # There ain't no standard :/ https://stackoverflow.com/questions/18636564/lat-long-or-long-lat
       do:
         Map.merge(attrs, %{
           "office_location" =>
             "{\"type\": \"Point\", \"coordinates\": [" <>
               attrs["office_latitude"] <>
               ", " <> attrs["office_longitude"] <> "]}"
         }),
       else:
         Map.merge(attrs, %{
           "office_location" => nil
         })
  end

  defp is_numeric(str) do
    case Float.parse(str) do
      {_num, ""} -> true
      _ -> false
    end
  end

  # FIXME: This is not transaction save, must remodel to Ecto.multi or transaction to be
  def import(%Plug.Upload{} = upload) do
    try do
      {:ok, upload.path |> File.stream!() |> import_jobs_csv_data_to_table_record()}
    rescue
      error ->
        IO.inspect({error, upload})
        {:error, upload}
    end
  end

  defp import_jobs_csv_data_to_table_record(csv_data) do
    column_names = import_jobs_get_csv_column_names(csv_data)

    csv_data
    |> CSV.parse_stream(skip_headers: true)
    |> Enum.map(fn row ->
      row
      |> Enum.with_index()
      |> Map.new(fn {val, num} -> {column_names[num], val} end)
      |> import_jobs_create_or_skip()
    end)
  end

  defp import_jobs_get_csv_column_names(csv_data) do
    csv_data
    |> CSV.parse_stream(skip_headers: false)
    |> Enum.fetch!(0)
    |> Enum.with_index()
    |> Map.new(fn {val, num} -> {num, val} end)
  end

  defp import_jobs_create_or_skip(row) do
    row = row |> convert_office_location_attrs()

    %Job{}
    |> Job.changeset(row)
    |> Repo.insert()
  end

  def update_job_with_geo_data(job, country_id) do
    changeset =
      job
      |> Job.changeset(%{
        country_id: country_id,
        fetched_country_data_last_datetime: NaiveDateTime.local_now()
      })

    changeset |> Repo.update()
  end

  def find_by_coords_in_radius_in_km_paginated(params, pagination_params),
    do: find_by_coords_in_radius_in_km_query(params) |> Repo.paginate(pagination_params)

  def find_by_coords_in_radius_in_km_query(%{
        "latitude" => latitude,
        "longitude" => longitude,
        "radius_in_km" => radius_in_km
      }) do
    radius_in_km = if radius_in_km > 2500, do: 2500, else: radius_in_km
    radius_in_m = radius_in_km * 1000
    point_of_origin = %Geo.Point{coordinates: {latitude, longitude}}

    query =
      from(j in Job,
        where: st_distance_in_meters(j.office_location, ^point_of_origin) < ^radius_in_m,
        select_merge: %{
          distance_to_origin_in_m: st_distance_in_meters(j.office_location, ^point_of_origin)
        },
        order_by: [
          asc_nulls_last: st_distance_in_meters(j.office_location, ^point_of_origin),
          asc: j.name
        ]
      )

    query
    |> preload(:professions)
    |> preload(:countries)
  end
end
