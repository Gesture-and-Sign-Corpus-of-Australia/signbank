defmodule SignbankWeb.SignLiveTest do
  use SignbankWeb.ConnCase

  import Phoenix.LiveViewTest
  import Signbank.DictionaryFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_sign(_) do
    sign = sign_fixture()
    %{sign: sign}
  end

  # TODO: Fix these tests, they're looking for undefined routes
  describe "Index" do
    setup [:create_sign]

    test "lists all signs", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/signs")

      assert html =~ "Listing Entries"
    end

    test "saves new sign", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/signs")

      assert index_live |> element("a", "New Sign") |> render_click() =~
               "New Sign"

      assert_patch(index_live, ~p"/signs/new")

      assert index_live
             |> form("#sign-form", sign: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#sign-form", sign: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/signs")

      html = render(index_live)
      assert html =~ "Sign created successfully"
    end

    test "updates sign in listing", %{conn: conn, sign: sign} do
      {:ok, index_live, _html} = live(conn, ~p"/signs")

      assert index_live |> element("#signs-#{sign.id} a", "Edit") |> render_click() =~
               "Edit Sign"

      assert_patch(index_live, ~p"/signs/#{sign}/edit")

      assert index_live
             |> form("#sign-form", sign: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#sign-form", sign: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/signs")

      html = render(index_live)
      assert html =~ "Sign updated successfully"
    end

    test "deletes sign in listing", %{conn: conn, sign: sign} do
      {:ok, index_live, _html} = live(conn, ~p"/signs")

      assert index_live |> element("#signs-#{sign.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#signs-#{sign.id}")
    end
  end

  # These tests are all wrong (based on the generators, heavy use of modals, undesirable)
  describe "Show" do
    setup [:create_sign]

    test "displays sign", %{conn: conn, sign: sign} do
      {:ok, _show_live, html} = live(conn, ~p"/signs/#{sign}")

      assert html =~ "Show Sign"
    end

    test "updates sign within modal", %{conn: conn, sign: sign} do
      {:ok, show_live, _html} = live(conn, ~p"/signs/#{sign}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Sign"

      assert_patch(show_live, ~p"/signs/#{sign}/show/edit")

      assert show_live
             |> form("#sign-form", sign: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#sign-form", sign: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/signs/#{sign}")

      html = render(show_live)
      assert html =~ "Sign updated successfully"
    end
  end
end
