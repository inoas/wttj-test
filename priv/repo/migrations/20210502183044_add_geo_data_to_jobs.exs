defmodule Wttj.Repo.Migrations.AddGeoDataToJobs do
  use Ecto.Migration

  def change do
    alter table(:jobs) do
			add :country_id, references(:countries, column: :id, type: :integer, on_update: :update_all, on_delete: :nothing), null: true
			add :fetched_country_data_last_datetime, :naive_datetime, null: true
    end

  end
end
