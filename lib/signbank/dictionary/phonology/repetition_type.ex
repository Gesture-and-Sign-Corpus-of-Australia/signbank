defmodule Signbank.Dictionary.Phonology.RepetitionType do
  @moduledoc """
  Provides helper methods for `repetition type` phonology fields
  TODO: give linguistic explanation as well
  """

  use Gettext, backend: Signbank.Gettext

  def to_string(:none), do: gettext("none")
  def to_string(:one_same_loc), do: gettext("one same loc")
  def to_string(:two_same_loc), do: gettext("two same loc")
  def to_string(:multiple_same_loc), do: gettext("multiple same loc")
  def to_string(:one_diff_locs), do: gettext("one diff locs")
  def to_string(:two_diff_locs), do: gettext("two diff locs")
  def to_string(:multiple_diff_locs), do: gettext("multiple diff locs")
  def to_string(nil), do: ""
end
