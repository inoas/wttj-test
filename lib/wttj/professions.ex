defmodule Wttj.Professions do
  @moduledoc """
  The Professions context.
  """

  import Ecto.Query, warn: false
  alias Wttj.Repo

  alias Wttj.Professions.Profession

  alias Wttj.Categories
  alias Wttj.Categories.Category

  alias NimbleCSV.RFC4180, as: CSV

  require Logger

  @doc """
  Returns the list of professions.

  ## Examples

      iex> list_professions()
      [%Profession{}, ...]

  """
  def list_professions do
    Profession
    |> order_by(asc: :name)
    |> Repo.all()
  end

  @doc """
  Gets a single profession.

  Raises `Ecto.NoResultsError` if the Profession does not exist.

  ## Examples

      iex> get_profession!(123)
      %Profession{}

      iex> get_profession!(456)
      ** (Ecto.NoResultsError)

  """
  def get_profession!(id), do: Repo.get!(Profession, id)

  @doc """
  Creates a profession.

  ## Examples

      iex> create_profession(%{field: value})
      {:ok, %Profession{}}

      iex> create_profession(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_profession(attrs \\ %{}) do
    %Profession{}
    |> Profession.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a profession.

  ## Examples

      iex> update_profession(profession, %{field: new_value})
      {:ok, %Profession{}}

      iex> update_profession(profession, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_profession(%Profession{} = profession, attrs) do
    profession
    |> Profession.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a profession.

  ## Examples

      iex> delete_profession(profession)
      {:ok, %Profession{}}

      iex> delete_profession(profession)
      {:error, %Ecto.Changeset{}}

  """
  def delete_profession(%Profession{} = profession) do
    Repo.delete(profession)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking profession changes.

  ## Examples

      iex> change_profession(profession)
      %Ecto.Changeset{data: %Profession{}}

  """
  def change_profession(%Profession{} = profession, attrs \\ %{}) do
    Profession.changeset(profession, attrs)
  end

  def import(%Plug.Upload{} = upload) do
    imports = upload.path |> File.stream!() |> import_professions_csv_data_to_table_record()
    IO.inspect(imports)
    {:ok, imports}
  end

  defp import_professions_get_csv_column_names(csv_data) do
    csv_data
    |> CSV.parse_stream(skip_headers: false)
    |> Enum.fetch!(0)
    |> Enum.with_index()
    |> Map.new(fn {val, num} -> {num, val} end)
  end

  defp import_professions_csv_data_to_table_record(csv_data) do
    column_names = import_professions_get_csv_column_names(csv_data)

    csv_data
    |> CSV.parse_stream(skip_headers: true)
    |> Enum.map(fn row ->
      row
      |> Enum.with_index()
      |> Map.new(fn {val, num} -> {column_names[num], val} end)
      |> import_professions_create_or_skip()
    end)
  end

  defp import_professions_create_or_skip(row) do
    case Profession |> Repo.get_by(id: row["id"]) do
      nil ->
        if Repo.exists?(from c in Category, where: c.name == ^row["category_name"]) == false do
          Logger.info("Creating missing category with name: " <> row["category_name"])
          Categories.create_category(%{name: row["category_name"]})
        end

        create_profession(row)

      profession ->
        {:ok, profession}
    end
  end
end
