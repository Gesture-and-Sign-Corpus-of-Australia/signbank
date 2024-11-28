defmodule Signbank.Dictionary.Phonology.Handpart do
  @moduledoc """
  Provides helper methods for `handpart` phonology fields
  TODO: give linguistic explanation as well
  """

  import SignbankWeb.Gettext

  def to_string(:palm), do: gettext("palm")
  def to_string(:back), do: gettext("back")
  def to_string(:radial), do: gettext("radial")
  def to_string(:ulnar), do: gettext("ulnar")
  def to_string(:fingertips), do: gettext("fingertips")
  def to_string(:wrist), do: gettext("wrist")
  def to_string(:forearm), do: gettext("forearm")
  def to_string(:elbow), do: gettext("elbow")
  def to_string(nil), do: ""
end
