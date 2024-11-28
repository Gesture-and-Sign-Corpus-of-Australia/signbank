defmodule Signbank.Dictionary.Phonology.HandshapeAllophone do
  @moduledoc """
  Provides helper methods for `handshape allophone` phonology fields
  TODO: give linguistic explanation as well
  """

  use Gettext, backend: Signbank.Gettext

  def to_string(:round_flat), do: gettext("round flat")
  def to_string(:round_flick), do: gettext("round flick")
  def to_string(:round_e), do: gettext("round E")
  def to_string(:okay_flat), do: gettext("okay flat")
  def to_string(:okay_f), do: gettext("okay F")
  def to_string(:point_d), do: gettext("point D")
  def to_string(:point_angled), do: gettext("point angled")
  def to_string(:point_angled_thumb), do: gettext("point angled thumb")
  def to_string(:hook_bent), do: gettext("hook bent")
  def to_string(:two_angle), do: gettext("two angle")
  def to_string(:spoon_thumb), do: gettext("spoon thumb")
  def to_string(:spoon_curved), do: gettext("spoon curved")
  def to_string(:letter_n), do: gettext("letter n")
  def to_string(:three_curved), do: gettext("three curved")
  def to_string(:three_bent), do: gettext("three bent")
  def to_string(:four_curved), do: gettext("four curved")
  def to_string(:spread_angled), do: gettext("spread angled")
  def to_string(:ball_bent), do: gettext("ball bent")
  def to_string(:flat_b), do: gettext("flat B")
  def to_string(:flat_angled), do: gettext("flat angled")
  def to_string(:flat_b_angled), do: gettext("flat B angled")
  def to_string(:thick_open), do: gettext("thick open")
  def to_string(:cup_thumb), do: gettext("cup thumb")
  def to_string(:cup_flush), do: gettext("cup flush")
  def to_string(:good_bent), do: gettext("good bent")
  def to_string(:bad_bent), do: gettext("bad bent")
  def to_string(:gun_bent), do: gettext("gun bent")
  def to_string(:letter_c_open), do: gettext("letter C open")
  def to_string(:small_open), do: gettext("small open")
  def to_string(:eight_curved), do: gettext("eight curved")
  def to_string(:fist_a), do: gettext("fist A")
  def to_string(:soon_flick), do: gettext("soon flick")
  def to_string(:soon_closed), do: gettext("soon closed")
  def to_string(:ten_tip), do: gettext("ten tip")
  def to_string(:ten_flat), do: gettext("ten flat")
  def to_string(:ten_tip_open), do: gettext("ten tip open")
  def to_string(:write_flat), do: gettext("write flat")
  def to_string(:write_flick), do: gettext("write flick")
  def to_string(:salt_closed), do: gettext("salt closed")
  def to_string(:salt_flick), do: gettext("salt flick")
  def to_string(:animal_closed), do: gettext("animal closed")
  def to_string(nil), do: ""
end
