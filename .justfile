set dotenv-load := true
dev:
  iex --name signbank@127.0.0.1 --cookie signbankdevelopment -S mix phx.server

test:
  MIX_ENV=test mix test

dbreset:
  mix ecto.reset
