defmodule SignbankWeb.PageController do
  use SignbankWeb, :controller

  def home(conn, _params), do: render(conn, :home)
  def acknowledgements(conn, _params), do: render(conn, :acknowledgements)
  def classes(conn, _params), do: render(conn, :classes)
  def community(conn, _params), do: render(conn, :community)
  def corpus(conn, _params), do: render(conn, :corpus)
  def dictionary(conn, _params), do: render(conn, :dictionary)
  def annotations(conn, _params), do: render(conn, :annotations)
  def grammar(conn, _params), do: render(conn, :grammar)
  def history(conn, _params), do: render(conn, :history)
  def vocabulary(conn, _params), do: render(conn, :vocabulary)
  def terms_and_conditions(conn, _params), do: render(conn, :terms_and_conditions)
end
