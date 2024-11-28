defmodule Signbank.Dictionary.Phonology.Path do
  @moduledoc """
  Provides helper methods for `path` phonology fields
  TODO: give linguistic explanation as well
  """

  use Gettext, backend: Signbank.Gettext

  def to_string(:none), do: gettext("none")
  def to_string(:straight), do: gettext("straight")
  def to_string(:diagonal), do: gettext("diagonal")
  def to_string(:arc), do: gettext("arc")
  def to_string(:curved), do: gettext("curved")
  def to_string(:wavy), do: gettext("wavy")
  def to_string(:zig_zag), do: gettext("zig zag")
  def to_string(:circular), do: gettext("circular")
  def to_string(:spiral), do: gettext("spiral")
  def to_string(nil), do: ""
end
