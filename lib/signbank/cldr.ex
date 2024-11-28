defmodule Signbank.Cldr do
  @moduledoc """
  Define a backend module that will host our
  Cldr configuration and public API.

  Most function calls in Cldr will be calls
  to functions on this module.
  """
  use Cldr,
    default_locale: "en",
    locales: ["en"],
    gettext: Signbank.Gettext,
    otp_app: :signbank,
    providers: [Cldr.Number, Cldr.List],
    generate_docs: true,
    force_locale_download: false
end
