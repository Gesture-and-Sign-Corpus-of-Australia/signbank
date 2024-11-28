defmodule Signbank.Dictionary.Phonology.Handshape do
  @moduledoc """
  Provides helper methods for `handshape` phonology fields
  TODO: give linguistic explanation as well
  """

  import SignbankWeb.Gettext

  def to_string(:relaxed), do: gettext("relaxed")
  def to_string(:round), do: gettext("round")
  def to_string(:okay), do: gettext("okay")
  def to_string(:point), do: gettext("point")
  def to_string(:hook), do: gettext("hook")
  def to_string(:two), do: gettext("two")
  def to_string(:kneel), do: gettext("kneel")
  def to_string(:perth), do: gettext("perth")
  def to_string(:spoon), do: gettext("spoon")
  def to_string(:letter_n), do: gettext("letter N")
  def to_string(:wish), do: gettext("wish")
  def to_string(:three), do: gettext("three")
  def to_string(:mother), do: gettext("mother")
  def to_string(:letter_m), do: gettext("letter M")
  def to_string(:four), do: gettext("four")
  def to_string(:spread), do: gettext("spread")
  def to_string(:ball), do: gettext("ball")
  def to_string(:flat), do: gettext("flat")
  def to_string(:thick), do: gettext("thick")
  def to_string(:cup), do: gettext("cup")
  def to_string(:good), do: gettext("good")
  def to_string(:bad), do: gettext("bad")
  def to_string(:gun), do: gettext("gun")
  def to_string(:buckle), do: gettext("buckle")
  def to_string(:letter_c), do: gettext("letter C")
  def to_string(:small), do: gettext("small")
  def to_string(:seven_old), do: gettext("seven (old)")
  def to_string(:eight), do: gettext("eight")
  def to_string(:nine), do: gettext("nine")
  def to_string(:fist), do: gettext("fist")
  def to_string(:soon), do: gettext("soon")
  def to_string(:ten), do: gettext("ten")
  def to_string(:write), do: gettext("write")
  def to_string(:salt), do: gettext("salt")
  def to_string(:duck), do: gettext("duck")
  def to_string(:middle), do: gettext("middle")
  def to_string(:rude), do: gettext("rude")
  def to_string(:ambivalent), do: gettext("ambivalent")
  def to_string(:love), do: gettext("love")
  def to_string(:animal), do: gettext("animal")
  def to_string(:queer), do: gettext("queer")
  def to_string(nil), do: ""
end
