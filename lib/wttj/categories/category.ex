defmodule Wttj.Categories.Category do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Phoenix.Param, key: :name}
  @primary_key {:name, :string, autogenerate: false}

  schema "categories" do
    timestamps()

    has_many :professions, Wttj.Professions.Profession, foreign_key: :category_name
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
