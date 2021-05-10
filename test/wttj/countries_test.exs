defmodule Wttj.CountriesTest do
  use Wttj.DataCase

  alias Wttj.Countries

  describe "countries" do
    alias Wttj.Countries.Country

    @valid_attrs %{
      continent_code: "some continent_code",
      continent_name: "some continent_name",
      name: "some name",
      number: 42,
      three_letter_code: "some three_letter_code",
      two_letter_code: "some two_letter_code"
    }
    @update_attrs %{
      continent_code: "some updated continent_code",
      continent_name: "some updated continent_name",
      name: "some updated name",
      number: 43,
      three_letter_code: "some updated three_letter_code",
      two_letter_code: "some updated two_letter_code"
    }
    @invalid_attrs %{
      continent_code: nil,
      continent_name: nil,
      name: nil,
      number: nil,
      three_letter_code: nil,
      two_letter_code: nil
    }

    def country_fixture(attrs \\ %{}) do
      {:ok, country} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Countries.create_country()

      country
    end

    test "list_countries/0 returns all countries" do
      country = country_fixture()
      assert Countries.list_countries() == [country]
    end

    test "get_country!/1 returns the country with given id" do
      country = country_fixture()
      assert Countries.get_country!(country.id) == country
    end

    test "create_country/1 with valid data creates a country" do
      assert {:ok, %Country{} = country} = Countries.create_country(@valid_attrs)
      assert country.continent_code == "some continent_code"
      assert country.continent_name == "some continent_name"
      assert country.name == "some name"
      assert country.number == 42
      assert country.three_letter_code == "some three_letter_code"
      assert country.two_letter_code == "some two_letter_code"
    end

    test "create_country/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Countries.create_country(@invalid_attrs)
    end

    test "update_country/2 with valid data updates the country" do
      country = country_fixture()
      assert {:ok, %Country{} = country} = Countries.update_country(country, @update_attrs)
      assert country.continent_code == "some updated continent_code"
      assert country.continent_name == "some updated continent_name"
      assert country.name == "some updated name"
      assert country.number == 43
      assert country.three_letter_code == "some updated three_letter_code"
      assert country.two_letter_code == "some updated two_letter_code"
    end

    test "update_country/2 with invalid data returns error changeset" do
      country = country_fixture()
      assert {:error, %Ecto.Changeset{}} = Countries.update_country(country, @invalid_attrs)
      assert country == Countries.get_country!(country.id)
    end

    test "delete_country/1 deletes the country" do
      country = country_fixture()
      assert {:ok, %Country{}} = Countries.delete_country(country)
      assert_raise Ecto.NoResultsError, fn -> Countries.get_country!(country.id) end
    end

    test "change_country/1 returns a country changeset" do
      country = country_fixture()
      assert %Ecto.Changeset{} = Countries.change_country(country)
    end
  end
end
