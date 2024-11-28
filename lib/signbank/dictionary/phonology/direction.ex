defmodule Signbank.Dictionary.Phonology.Direction do
  @moduledoc """
  Provides helper methods for `direction` phonology fields
  TODO: give linguistic explanation as well
  """

  use Gettext, backend: Signbank.Gettext

  def to_string(:none), do: gettext("none")
  def to_string(:up), do: gettext("up")
  def to_string(:down), do: gettext("down")
  def to_string(:up_and_down), do: gettext("up and down")
  def to_string(:left), do: gettext("left")
  def to_string(:right), do: gettext("right")
  def to_string(:side_to_side), do: gettext("side to side")
  def to_string(:away), do: gettext("away")
  def to_string(:towards), do: gettext("towards")
  def to_string(:to_and_fro), do: gettext("to and fro")
  def to_string(nil), do: ""
end
