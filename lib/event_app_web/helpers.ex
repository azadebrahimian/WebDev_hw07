defmodule EventAppWeb.Helpers do
  def have_current_user?(conn) do
    conn.assigns[:current_user] != nil
  end

  def current_user_id?(conn, user_id) do
    user = conn.assigns[:current_user]
    user && user.id == user_id
  end

  def current_user_id(conn) do
    user = conn.assigns[:current_user]
    user && user.id
  end

  def can_delete_comment?(conn, event_owner, comm_owner) do
    user = conn.assigns[:current_user]
    user && (user.id == comm_owner || user.id == event_owner)
  end

  def get_user_name(user_id) do
    EventApp.Users.get_user!(user_id).name
  end

  def get_user(user_id) do
    EventApp.Users.get_user!(user_id)
  end

  def is_event_owner?(conn, ev) do
    ev.user_id == conn.assigns[:current_user].id
  end

  def is_current_user_inv?(conn, inv) do
    user = conn.assigns[:current_user]
    user && (user.id == inv.user_id)
  end

  def get_yes(invs) do
    if length(invs) == 0 do
      0
    else
      if hd(invs).response == "Yes" do
        1 + get_yes(tl(invs))
      else
        get_yes(tl(invs))
      end
    end
  end

  def get_maybe(invs) do
    if length(invs) == 0 do
      0
    else
      if hd(invs).response == "Maybe" do
        1 + get_maybe(tl(invs))
      else
        get_maybe(tl(invs))
      end
    end
  end

  def get_no(invs) do
    if length(invs) == 0 do
      0
    else
      if hd(invs).response == "No" do
        1 + get_no(tl(invs))
      else
        get_no(tl(invs))
      end
    end
  end

  def get_havent(invs) do
    if length(invs) == 0 do
      0
    else
      if hd(invs).response == "Haven't responded" do
        1 + get_havent(tl(invs))
      else
        get_havent(tl(invs))
      end
    end
  end

  def invited?(conn) do
    user = conn.assigns[:current_user]
    event = conn.assigns[:event]
    user.id == event.user_id || invited_help(user.id, event.invitees)
  end

  def invited_help(u, i) do
    if length(i) == 0 do
      false
    else 
      if hd(i).user_id == u do
        true
      else
        invited_help(u, tl(i))
      end
    end
  end

  def ii(u, p) do
    IO.inspect {u,p}
  end
end
