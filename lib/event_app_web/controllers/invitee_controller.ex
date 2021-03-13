defmodule EventAppWeb.InviteeController do
  use EventAppWeb, :controller

  alias EventApp.Invitees
  alias EventApp.Invitees.Invitee
  alias EventApp.Users
  alias EventApp.Users.User

  def index(conn, _params) do
    invitees = Invitees.list_invitees()
    render(conn, "index.html", invitees: invitees)
  end

  def new(conn, _params) do
    changeset = Invitees.change_invitee(%Invitee{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"invitee" => invitee_params}) do
    inv_email = invitee_params["email"]
   
    user_email = Users.get_user_by_email(inv_email)
    
    if user_email != nil do
      invitee_params = invitee_params
      |> Map.put("user_id", user_email.id)    
   
      case Invitees.create_invitee(invitee_params) do
        {:ok, invitee} ->
          conn
          |> put_flash(:info, "Invitee created successfully.")
          |> redirect(to: Routes.event_path(conn, :show, invitee.event_id))

        {:error, %Ecto.Changeset{} = changeset} ->
          put_flash(conn, :error, "Can't invite unregistered user.")
          render(conn, "new.html", changeset: changeset)
      end
    else
      conn
      |> put_flash(:error, "Can't invite unregistered user.")
      |> redirect(to: Routes.event_path(conn, :show, invitee_params["event_id"]))
    end
  end

  def show(conn, %{"id" => id}) do
    invitee = Invitees.get_invitee!(id)
    render(conn, "show.html", invitee: invitee)
  end

  def edit(conn, %{"id" => id}) do
    invitee = Invitees.get_invitee!(id)
    changeset = Invitees.change_invitee(invitee)
    render(conn, "edit.html", invitee: invitee, changeset: changeset)
  end

  def update(conn, %{"id" => id, "invitee" => invitee_params}) do
    invitee = Invitees.get_invitee!(id)
    case Invitees.update_invitee(invitee, invitee_params) do
      {:ok, invitee} ->
        conn
        |> put_flash(:info, "Invitee updated successfully.")
        |> redirect(to: Routes.event_path(conn, :show, invitee.event_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", invitee: invitee, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    invitee = Invitees.get_invitee!(id)
    {:ok, _invitee} = Invitees.delete_invitee(invitee)

    conn
    |> put_flash(:info, "Invitee deleted successfully.")
    |> redirect(to: Routes.invitee_path(conn, :index))
  end
end
