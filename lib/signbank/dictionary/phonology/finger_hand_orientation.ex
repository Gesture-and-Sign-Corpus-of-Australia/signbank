defmodule Signbank.Dictionary.Phonology.FingerHandOrientation do
  @moduledoc """
  Provides helper methods for `finger hand orientation` phonology fields
  TODO: give linguistic explanation as well
  """

  use Gettext, backend: Signbank.Gettext

  def to_string(:up_left), do: gettext("up left")
  def to_string(:up), do: gettext("up")
  def to_string(:up_right), do: gettext("up right")
  def to_string(:up_away), do: gettext("up away")
  def to_string(:up_towards), do: gettext("up towards")
  def to_string(:left), do: gettext("left")
  def to_string(:away), do: gettext("away")
  def to_string(:away_left), do: gettext("away left")
  def to_string(:away_right), do: gettext("away right")
  def to_string(:away_down), do: gettext("away down")
  def to_string(:towards), do: gettext("towards")
  def to_string(:down), do: gettext("down")
  def to_string(:right), do: gettext("right")
  def to_string(nil), do: ""
end
