defmodule Wttj.Countries do
  @moduledoc """
  The Countries context.
  """

  import Ecto.Query, warn: false
  alias Wttj.Repo

  alias Wttj.Countries.Country

  @doc """
  Returns the list of countries.

  ## Examples

      iex> list_countries()
      [%Country{}, ...]

  """
  def list_countries do
    Repo.all(Country)
  end

  @doc """
  Gets a single country.

  Raises `Ecto.NoResultsError` if the Country does not exist.

  ## Examples

      iex> get_country!(123)
      %Country{}

      iex> get_country!(456)
      ** (Ecto.NoResultsError)

  """
  def get_country!(id), do: Repo.get!(Country, id)

  @doc """
  Creates a country.

  ## Examples

      iex> create_country(%{field: value})
      {:ok, %Country{}}

      iex> create_country(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_country(attrs \\ %{}) do
    %Country{}
    |> Country.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a country.

  ## Examples

      iex> update_country(country, %{field: new_value})
      {:ok, %Country{}}

      iex> update_country(country, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_country(%Country{} = country, attrs) do
    country
    |> Country.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a country.

  ## Examples

      iex> delete_country(country)
      {:ok, %Country{}}

      iex> delete_country(country)
      {:error, %Ecto.Changeset{}}

  """
  def delete_country(%Country{} = country) do
    Repo.delete(country)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking country changes.

  ## Examples

      iex> change_country(country)
      %Ecto.Changeset{data: %Country{}}

  """
  def change_country(%Country{} = country, attrs \\ %{}) do
    Country.changeset(country, attrs)
  end

  def import(%Plug.Upload{} = upload) do
    # FIXME: This is not transaction save, must remodel to Ecto.multi or transaction to be
    try do
      {:ok, upload.path |> File.read!() |> import_countries_json_data_to_table_record()}
    rescue
      error ->
        IO.inspect({error, upload})
        {:error, upload}
    end
  end

  defp import_countries_json_data_to_table_record(json_data) do
    json_data
    |> Jason.decode!()
    |> Enum.map(fn row ->
      row |> import_countries_create_or_skip()
    end)
  end

  defp import_countries_create_or_skip(row) do
    case Country |> Repo.get_by(name: row["Country_Name"]) do
      nil ->
        if Repo.exists?(from c in Country, where: c.name == ^row["Country_Name"]) == false do
          IO.inspect("Creating missing country with name: " <> row["Country_Name"])

          create_country(%{
            continent_code: row["Continent_Code"],
            continent_name: row["Continent_Name"],
            name: row["Country_Name"],
            number: row["Country_Number"],
            three_letter_code: row["Three_Letter_Country_Code"],
            two_letter_code: row["Two_Letter_Country_Code"]
          })
        end

      country ->
        {:ok, country}
    end
  end
end
