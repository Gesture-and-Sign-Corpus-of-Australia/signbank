defmodule SignbankWeb.Plugs.RewriteURL do
  @defmodule """
  Rewrites legacy django-based Signbank URLs to the new format.

  TODO: list specific rewrites
  """
  use SignbankWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  def init(default), do: default

  def call(%Plug.Conn{request_path: path} = conn, _) do
    if String.starts_with?(conn.request_path, "/dictionary/words") do
      %{"q" => q, "n" => n} =
        Regex.named_captures(
          ~r/\/dictionary\/words\/(?<q>[\w ]+)-(?<n>\d+)\.html/,
          URI.decode(conn.request_path)
        )

      conn
      |> put_status(301)
      |> redirect(to: ~p"/dictionary?#{%{"q" => q, "n" => n}}")
      |> halt()
    else
      conn
    end
  end
end
