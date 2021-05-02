defmodule Wttj.Repo.Migrations.DropUniqueProfessionName do
  use Ecto.Migration

  def change do
		drop unique_index(:professions, [:name])
  end

end
