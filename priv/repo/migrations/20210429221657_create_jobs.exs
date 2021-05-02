defmodule Wttj.Repo.Migrations.CreateJobs do
  use Ecto.Migration

  def change do
    create table(:jobs) do
      add :profession_id, references(:professions, on_delete: :nothing), null: false
      add :contract_type, :string, null: false
      add :name, :string, null: false
      add :office_location, :string, null: true

      timestamps()
    end

    create index(:jobs, [:profession_id])
  end
end
