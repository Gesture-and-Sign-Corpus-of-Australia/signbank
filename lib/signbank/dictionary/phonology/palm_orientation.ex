defmodule Signbank.Dictionary.Phonology.PalmOrientation do
  @moduledoc """
  Provides helper methods for `palm orientation` phonology fields
  TODO: give linguistic explanation as well
  """

  use Gettext, backend: Signbank.Gettext

  def to_string(:towards), do: gettext("towards")
  def to_string(:left), do: gettext("left")
  def to_string(:away), do: gettext("away")
  def to_string(:up), do: gettext("up")
  def to_string(:down), do: gettext("down")
  def to_string(:right), do: gettext("right")
  def to_string(nil), do: ""
end
