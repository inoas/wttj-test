defmodule Wttj.Repo.Migrations.ChangeOfficeLocationToPostgisPoint do
  use Ecto.Migration

  def up do
			alter table(:jobs) do
				remove :office_location
			end
			execute("SELECT AddGeometryColumn ('jobs', 'office_location', 4326, 'POINT', 2);")
			# execute("ALTER TABLE jobs ADD COLUMN office_location GEOGRAPHY(POINT,4326);")
			# use :geography ?
			execute("CREATE INDEX office_location_index ON jobs USING GIST (office_location);")
  end

	def down do
			execute("DROP INDEX office_location_index")
			alter table(:jobs) do
				remove :office_location
				add :office_location, :string
			end
	end
end
