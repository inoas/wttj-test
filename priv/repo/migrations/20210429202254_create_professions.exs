defmodule Wttj.Repo.Migrations.CreateProfessions do
  use Ecto.Migration

  def change do
    create table(:professions) do
      add :name, :string
      add :category_name, references(:categories, column: :name, type: :string, on_delete: :nothing)

      timestamps()
    end

    create index(:professions, [:category_name])
  end
end
