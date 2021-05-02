defmodule Wttj.Repo.Migrations.CreateCountries do
  use Ecto.Migration

  def change do
    create table(:countries) do
      add :continent_code, :string, null: false
      add :continent_name, :string, null: false
      add :name, :string, null: false
      add :number, :integer, null: true
      add :three_letter_code, :string, null: true
      add :two_letter_code, :string, null: true

      timestamps()
    end

		create unique_index(:countries, [:name])
		create unique_index(:countries, [:number])
		create unique_index(:countries, [:three_letter_code])
		create unique_index(:countries, [:two_letter_code])
  end
end
