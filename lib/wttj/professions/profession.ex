defmodule Wttj.Professions.Profession do
  use Ecto.Schema
  import Ecto.Changeset

  schema "professions" do
    field :name, :string
    field :category_name, :id

    timestamps()
  end

  @doc false
  def changeset(profession, attrs) do
    profession
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
