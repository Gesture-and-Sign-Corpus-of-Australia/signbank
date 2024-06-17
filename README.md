# Signbank

To setup your Signbank development environment:

  * Install Elixir, the recommended way is: (other methods are [outlined here](https://elixir-lang.org/install.html#version-managers))
    * Start by installing [`asdf` version manager](https://asdf-vm.com/guide/getting-started.html)
    * Install the Erlang plugin https://github.com/asdf-vm/asdf-erlang
    * Install the Elixir plugin https://github.com/asdf-vm/asdf-elixir
    * Run `asdf install` in the root of this repo (This will install the correct versions of both Erlang and Elixir)
  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.


## Deployment

Auslan Signbank is hosted on an Ubuntu VM on the Australian Research Data Common's cloud, Nectar. It should work with any Linux server, although you will need to install and setup some things manually:
- Postgres
- A reverse proxy, since Signbank is not built to communicate over HTTPS directly. I recommend Caddy since it handles TLS certificates automatically. Nginx will work if you'd prefer.
- Tailscale (optional). Allows you to connect to the database from your local machine, without exposing it to the internet.
