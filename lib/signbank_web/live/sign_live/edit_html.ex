defmodule SignbankWeb.SignEditHTML do
  use SignbankWeb, :html

  # This will generate functions like `edit_phonology/1`, `edit_vocabulary/1`, etc.
  # based on the templates in `lib/signbank_web/live/sign_live/*`.
  embed_templates "sign_live/*"
end
