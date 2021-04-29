defmodule Wttj.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories, primary_key: false) do
      add(:name, :string, primary_key: true)

      timestamps()
    end
  end
end
