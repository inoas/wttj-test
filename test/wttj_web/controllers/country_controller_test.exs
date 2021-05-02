defmodule WttjWeb.CountryControllerTest do
  use WttjWeb.ConnCase

  alias Wttj.Countries

  @create_attrs %{continent_code: "some continent_code", continent_name: "some continent_name", name: "some name", number: 42, three_letter_code: "some three_letter_code", two_letter_code: "some two_letter_code"}
  @update_attrs %{continent_code: "some updated continent_code", continent_name: "some updated continent_name", name: "some updated name", number: 43, three_letter_code: "some updated three_letter_code", two_letter_code: "some updated two_letter_code"}
  @invalid_attrs %{continent_code: nil, continent_name: nil, name: nil, number: nil, three_letter_code: nil, two_letter_code: nil}

  def fixture(:country) do
    {:ok, country} = Countries.create_country(@create_attrs)
    country
  end

  describe "index" do
    test "lists all countries", %{conn: conn} do
      conn = get(conn, Routes.country_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Countries"
    end
  end

  describe "new country" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.country_path(conn, :new))
      assert html_response(conn, 200) =~ "New Country"
    end
  end

  describe "create country" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.country_path(conn, :create), country: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.country_path(conn, :show, id)

      conn = get(conn, Routes.country_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Country"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.country_path(conn, :create), country: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Country"
    end
  end

  describe "edit country" do
    setup [:create_country]

    test "renders form for editing chosen country", %{conn: conn, country: country} do
      conn = get(conn, Routes.country_path(conn, :edit, country))
      assert html_response(conn, 200) =~ "Edit Country"
    end
  end

  describe "update country" do
    setup [:create_country]

    test "redirects when data is valid", %{conn: conn, country: country} do
      conn = put(conn, Routes.country_path(conn, :update, country), country: @update_attrs)
      assert redirected_to(conn) == Routes.country_path(conn, :show, country)

      conn = get(conn, Routes.country_path(conn, :show, country))
      assert html_response(conn, 200) =~ "some updated continent_code"
    end

    test "renders errors when data is invalid", %{conn: conn, country: country} do
      conn = put(conn, Routes.country_path(conn, :update, country), country: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Country"
    end
  end

  describe "delete country" do
    setup [:create_country]

    test "deletes chosen country", %{conn: conn, country: country} do
      conn = delete(conn, Routes.country_path(conn, :delete, country))
      assert redirected_to(conn) == Routes.country_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.country_path(conn, :show, country))
      end
    end
  end

  defp create_country(_) do
    country = fixture(:country)
    %{country: country}
  end
end
