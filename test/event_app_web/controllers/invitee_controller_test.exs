defmodule EventAppWeb.InviteeControllerTest do
  use EventAppWeb.ConnCase

  alias EventApp.Invitees

  @create_attrs %{response: "some response"}
  @update_attrs %{response: "some updated response"}
  @invalid_attrs %{response: nil}

  def fixture(:invitee) do
    {:ok, invitee} = Invitees.create_invitee(@create_attrs)
    invitee
  end

  describe "index" do
    test "lists all invitees", %{conn: conn} do
      conn = get(conn, Routes.invitee_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Invitees"
    end
  end

  describe "new invitee" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.invitee_path(conn, :new))
      assert html_response(conn, 200) =~ "New Invitee"
    end
  end

  describe "create invitee" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.invitee_path(conn, :create), invitee: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.invitee_path(conn, :show, id)

      conn = get(conn, Routes.invitee_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Invitee"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.invitee_path(conn, :create), invitee: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Invitee"
    end
  end

  describe "edit invitee" do
    setup [:create_invitee]

    test "renders form for editing chosen invitee", %{conn: conn, invitee: invitee} do
      conn = get(conn, Routes.invitee_path(conn, :edit, invitee))
      assert html_response(conn, 200) =~ "Edit Invitee"
    end
  end

  describe "update invitee" do
    setup [:create_invitee]

    test "redirects when data is valid", %{conn: conn, invitee: invitee} do
      conn = put(conn, Routes.invitee_path(conn, :update, invitee), invitee: @update_attrs)
      assert redirected_to(conn) == Routes.invitee_path(conn, :show, invitee)

      conn = get(conn, Routes.invitee_path(conn, :show, invitee))
      assert html_response(conn, 200) =~ "some updated response"
    end

    test "renders errors when data is invalid", %{conn: conn, invitee: invitee} do
      conn = put(conn, Routes.invitee_path(conn, :update, invitee), invitee: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Invitee"
    end
  end

  describe "delete invitee" do
    setup [:create_invitee]

    test "deletes chosen invitee", %{conn: conn, invitee: invitee} do
      conn = delete(conn, Routes.invitee_path(conn, :delete, invitee))
      assert redirected_to(conn) == Routes.invitee_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.invitee_path(conn, :show, invitee))
      end
    end
  end

  defp create_invitee(_) do
    invitee = fixture(:invitee)
    %{invitee: invitee}
  end
end
