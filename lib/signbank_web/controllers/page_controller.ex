defmodule SignbankWeb.PageController do
  use SignbankWeb, :controller

  def home(conn, _params), do: render(conn, :home)
  def acknowledgements(conn, _params), do: render(conn, :acknowledgements)
  def classes(conn, _params), do: render(conn, :classes)
  def community(conn, _params), do: render(conn, :community)
  def corpus(conn, _params), do: render(conn, :corpus)
  def dictionary(conn, _params), do: render(conn, :dictionary)
  def annotations(conn, _params), do: render(conn, :annotations)
  def history(conn, _params), do: render(conn, :history)
  def vocabulary(conn, _params), do: render(conn, :vocabulary)
  def terms_and_conditions(conn, _params), do: render(conn, :terms_and_conditions)
  def settings(conn, _params), do: render(conn, :settings)
  def number_signs(conn, _params), do: render(conn, :number_signs)
  def finger_spelling(conn, _params), do: render(conn, :finger_spelling)
  def auslan_spell(conn, _params), do: render(conn, :auslan_spell)
  def one_handed(conn, _params), do: render(conn, :one_handed)
  def practice(conn, _params), do: render(conn, :practice)
end
