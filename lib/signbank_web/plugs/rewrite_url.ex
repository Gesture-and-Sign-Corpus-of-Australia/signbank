defmodule SignbankWeb.Plugs.RewriteURL do
  @moduledoc """
  Rewrites legacy django-based Signbank URLs to the new format.

  TODO: list specific rewrites
  """

  use SignbankWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  def init(default), do: default

  def call(%Plug.Conn{request_path: path} = conn, _) do
    cond do
      String.starts_with?(path, "/dictionary/words") ->
        %{"q" => q, "n" => n} =
          Regex.named_captures(
            ~r/\/dictionary\/words\/(?<q>[\w ]+)-(?<n>\d+)\.html/,
            URI.decode(path)
          )

        conn
        |> put_status(301)
        |> redirect(to: ~p"/dictionary?#{%{"q" => q, "n" => n}}")
        |> halt()

      path == "/spell/twohanded.html" ->
        conn
        |> put_status(301)
        |> redirect(to: ~p"/learning/finger-spelling")
        |> halt()

      path == "/spell/onehanded.html" ->
        conn
        |> put_status(301)
        |> redirect(to: ~p"/learning/finger-spelling/one-handed")
        |> halt()

      path == "/spell/practice.html" ->
        conn
        |> put_status(301)
        |> redirect(to: ~p"/learning/finger-spelling/practice")
        |> halt()

      path == "/numbersigns.html" ->
        conn
        |> put_status(301)
        |> redirect(to: ~p"/learning/number-signs")
        |> halt()

      true ->
        conn
    end
  end
end
