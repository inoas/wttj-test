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

    has_many :jobs, Wttj.Jobs.Job, foreign_key: :profession_id
  end

  @doc false
  def changeset(profession, attrs) do
    profession
    |> cast(attrs, [:name, :category_name])
    |> validate_required([:name, :category_name])
  end
end
