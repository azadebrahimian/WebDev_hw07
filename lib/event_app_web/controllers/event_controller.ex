defmodule EventAppWeb.EventController do
  use EventAppWeb, :controller

  alias EventApp.Events
  alias EventApp.Events.Event
  alias EventAppWeb.Plugs

  plug Plugs.RequireUser when action in [:new, :edit, :create, :update]
  plug :fetch_event when action in [:show, :edit, :update, :delete]
  plug :require_owner when action in [:edit, :update, :delete]
  plug :require_viewer when action in [:show]

  def fetch_event(conn, _args) do
    id = conn.params["id"]
    event = Events.get_event!(id)
    assign(conn, :event, event)
  end

  def require_owner(conn, _args) do
    user = conn.assigns[:current_user]
    event = conn.assigns[:event]
    
    if user.id == event.user_id do 
      conn
    else
      conn
      |> put_flash(:error, "Can't mess with an event that isn't yours.")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end

  def require_viewer(conn, _args) do 
    user = conn.assigns[:current_user]
    event = conn.assigns[:event]
    invitees = Events.load_invitees(event).invitees
    # INCLUDE OWNER
    if user && (user.id == event.user_id || check_if_invited(invitees, user.id)) do
      conn
    else
      conn
      |> put_flash(:error, "Sorry, you weren't invited :(")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end

  def check_if_invited(invs, user) do
    if length(invs) == 0 do
      false
    else
      if hd(invs).user_id == user do
        true
      else
        check_if_invited(tl(invs), user)
      end
    end
  end

  def index(conn, _params) do
    events = Events.list_events()
    render(conn, "index.html", events: events)
  end

  def new(conn, _params) do
    changeset = Events.change_event(%Event{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"event" => event_params}) do
    event_params = event_params
    |> Map.put("user_id", conn.assigns[:current_user].id)

    case Events.create_event(event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event created successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    #event = Events.get_event!(id)
    event = conn.assigns[:event]
    |> Events.load_comments()

    event = event
    |> Events.load_invitees()

    comm = %EventApp.Comments.Comment{
      event_id: event.id,
      user_id: current_user_id(conn)
    }

    inv = %EventApp.Invitees.Invitee{
      response: "Haven't responded",
      user_id: current_user_id(conn),
      event_id: event.id,
    }

    new_comment = EventApp.Comments.change_comment(comm)
    new_invitee = EventApp.Invitees.change_invitee(inv)
    render(conn, "show.html", event: event, new_comment: new_comment, new_invitee: new_invitee)
  end

  def edit(conn, %{"id" => id}) do
    #event = Events.get_event!(id)
    event = conn.assigns[:event]
    changeset = Events.change_event(event)
    render(conn, "edit.html", event: event, changeset: changeset)
  end

  def update(conn, %{"id" => id, "event" => event_params}) do
    #event = Events.get_event!(id)
    event = conn.assigns[:event]

    case Events.update_event(event, event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event updated successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", event: event, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    #event = Events.get_event!(id)
    event = conn.assigns[:event]
    {:ok, _event} = Events.delete_event(event)

    conn
    |> put_flash(:info, "Event deleted successfully.")
    |> redirect(to: Routes.event_path(conn, :index))
  end
end
