defmodule Signbank.Dictionary.Phonology.Side do
  @moduledoc """
  Provides helper methods for `side` phonology fields
  TODO: give linguistic explanation as well
  """
  use Gettext, backend: Signbank.Gettext

  def to_string(:rightside), do: gettext("rightside")
  def to_string(:leftside), do: gettext("leftside")
  def to_string(:left_to_rightside), do: gettext("left to rightside")
  def to_string(:right_to_leftside), do: gettext("right to leftside")
  def to_string(nil), do: ""
end
