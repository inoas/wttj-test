defmodule Wttj.Countries.Country do
  use Ecto.Schema
  import Ecto.Changeset

  schema "countries" do
    field :continent_code, :string
    field :continent_name, :string
    field :name, :string
    field :number, :integer
    field :three_letter_code, :string
    field :two_letter_code, :string

    timestamps()
  end

  @doc false
  def changeset(country, attrs) do
    country
    |> cast(attrs, [
      :continent_code,
      :continent_name,
      :name,
      :number,
      :three_letter_code,
      :two_letter_code
    ])
    |> validate_required([:continent_code, :continent_name, :name])
  end
end
