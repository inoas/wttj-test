defmodule WttjWeb.ProfessionController do
  use WttjWeb, :controller

  alias Wttj.Professions
  alias Wttj.Professions.Profession

  alias Wttj.Categories

  def index(conn, _params) do
    professions = Professions.list_professions()
    render(conn, "index.html", professions: professions)
  end

  def new(conn, _params) do
    categories = Categories.list_categories()
    changeset = Professions.change_profession(%Profession{})
    render(conn, "new.html", changeset: changeset, categories: categories)
  end

  def create(conn, %{"profession" => profession_params}) do
    case Professions.create_profession(profession_params) do
      {:ok, profession} ->
        conn
        |> put_flash(:info, "Profession created successfully.")
        |> redirect(to: Routes.profession_path(conn, :show, profession))

      {:error, %Ecto.Changeset{} = changeset} ->
        categories = Categories.list_categories()
        render(conn, "new.html", changeset: changeset, categories: categories)
    end
  end

  def show(conn, %{"id" => id}) do
    profession = Professions.get_profession!(id)
    render(conn, "show.html", profession: profession)
  end

  def edit(conn, %{"id" => id}) do
    profession = Professions.get_profession!(id)
    categories = Categories.list_categories()
    changeset = Professions.change_profession(profession)

    render(conn, "edit.html", profession: profession, changeset: changeset, categories: categories)
  end

  def update(conn, %{"id" => id, "profession" => profession_params}) do
    profession = Professions.get_profession!(id)

    case Professions.update_profession(profession, profession_params) do
      {:ok, profession} ->
        conn
        |> put_flash(:info, "Profession updated successfully.")
        |> redirect(to: Routes.profession_path(conn, :show, profession))

      {:error, %Ecto.Changeset{} = changeset} ->
        categories = Categories.list_categories()

        render(conn, "edit.html",
          profession: profession,
          changeset: changeset,
          categories: categories
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    profession = Professions.get_profession!(id)
    {:ok, _profession} = Professions.delete_profession(profession)

    conn
    |> put_flash(:info, "Profession deleted successfully.")
    |> redirect(to: Routes.profession_path(conn, :index))
  end
end
