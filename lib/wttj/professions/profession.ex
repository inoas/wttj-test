defmodule Wttj.Professions.Profession do
  use Ecto.Schema
  import Ecto.Changeset

  schema "professions" do
    field :name, :string

    timestamps()

    belongs_to :categories, Wttj.Categories.Category,
      foreign_key: :category_name,
      references: :name,
      type: :string
  end

  @doc false
  def changeset(profession, attrs) do
    profession
    |> cast(attrs, [:name, :category_name])
    |> validate_required([:name, :category_name])
    |> unique_constraint(:name)
  end
end
