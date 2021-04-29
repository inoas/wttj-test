defmodule Wttj.Repo.Migrations.CreateProfessions do
  use Ecto.Migration

  def change do
    create table(:professions) do
      add :name, :string, null: false
      add :category_name, references(:categories, column: :name, type: :string, on_delete: :nothing), null: false

      timestamps()
    end

		create unique_index(:professions, [:name])
    create index(:professions, [:category_name])

  end
end
