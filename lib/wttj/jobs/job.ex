defmodule Wttj.Jobs.Job do
  use Ecto.Schema
  import Ecto.Changeset

  @contract_type_enum_values [
    :APPRENTICESHIP,
    :FREELANCE,
    :FULL_TIME,
    :INTERNSHIP,
    :PART_TIME,
    :TEMPORARY,
    :VIE
  ]

  schema "jobs" do
    field :name, :string
    field :contract_type, Ecto.Enum, values: @contract_type_enum_values
    field :office_location_latitude, :float, virtual: true
    field :office_location_longitude, :float, virtual: true
    field :office_location, Geo.PostGIS.Geometry

    belongs_to :professions, Wttj.Professions.Profession,
      foreign_key: :profession_id,
      references: :id,
      type: :id

    timestamps()
  end

  @doc false
  def changeset(job, attrs) do
    job
    |> cast(attrs, [
      :profession_id,
      :contract_type,
      :name,
      :office_location_latitude,
      :office_location_longitude,
      :office_location
    ])
    |> validate_required([
      :profession_id,
      :contract_type,
      :name
    ])
  end
end
