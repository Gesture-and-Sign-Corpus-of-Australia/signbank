defmodule Signbank.Dictionary.Phonology.Location do
  @moduledoc """
  Provides helper methods for `location` phonology fields
  TODO: give linguistic explanation as well
  """

  import SignbankWeb.Gettext

  def to_string(:top_head), do: gettext("top head")
  def to_string(:forehead), do: gettext("forehead")
  def to_string(:temple), do: gettext("temple")
  def to_string(:eye), do: gettext("eye")
  def to_string(:cheekbone), do: gettext("cheekbone")
  def to_string(:nose), do: gettext("nose")
  def to_string(:whole_face), do: gettext("whole face")
  def to_string(:ear_or_side_head), do: gettext("ear or side head")
  def to_string(:cheek), do: gettext("cheek")
  def to_string(:mouth_or_lips), do: gettext("mouth or lips")
  def to_string(:chin), do: gettext("chin")
  def to_string(:neck), do: gettext("neck")
  def to_string(:shoulder), do: gettext("shoulder")
  def to_string(:high_neutral_space), do: gettext("high neutral space")
  def to_string(:chest), do: gettext("chest")
  def to_string(:neutral_space), do: gettext("neutral space")
  def to_string(:stomach), do: gettext("stomach")
  def to_string(:low_neutral_space), do: gettext("low neutral space")
  def to_string(:waist), do: gettext("waist")
  def to_string(:below_waist), do: gettext("below waist")
  def to_string(:upper_arm), do: gettext("upper arm")
  def to_string(:elbow), do: gettext("elbow")
  def to_string(:pronated_forearm), do: gettext("pronated forearm")
  def to_string(:supinated_forearm), do: gettext("supinated forearm")
  def to_string(:pronated_wrist), do: gettext("pronated wrist")
  def to_string(:supinated_wrist), do: gettext("supinated wrist")
  def to_string(:palm), do: gettext("palm")
  def to_string(nil), do: ""
end
