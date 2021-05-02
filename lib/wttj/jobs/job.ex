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
    field :office_latitude, :float, virtual: true
    field :office_longitude, :float, virtual: true
    field :office_location, Geo.PostGIS.Geometry
    field :fetched_country_data_last_datetime, :naive_datetime

    belongs_to :professions, Wttj.Professions.Profession,
      foreign_key: :profession_id,
      references: :id,
      type: :id

    belongs_to :countries, Wttj.Countries.Country,
      foreign_key: :country_id,
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
      :office_latitude,
      :office_longitude,
      :office_location,
      :country_id,
      :fetched_country_data_last_datetime
    ])
    |> validate_required([
      :profession_id,
      :contract_type,
      :name
    ])
  end
end
