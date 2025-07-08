
differences between old and new (updating to 1.8)


missing changesets and validation around user.role

user_notifier emails don't have the fancy heex/html thing that I added




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



### Testing TODOs

#### keyword bolding in definitions

This is a fairly complex (and still flawed) regex, so we should have unit tests for it. Some examples of difficult definitions to bold correctly follow, with explanations of what could be troublesome.

- extra square-bracketed explanation after the `English = `
  ```
  A person who uses their strength or power to hurt or frighten other people. English = bully. [State school-based sign: used by former students of the Royal Institute for Deaf and Blind Children, Sydney.]
  ```
- Square-bracketed usage note at beginning
  ```
  [Often made with puffed cheeks] the act of going very fast in a vehicle, especially a car. English = speeding.
  ```
- Quoted keywords
  ```
  Used alone (pointed towards specific people) to mean that the person you are talking to is entirely responsible for doing something or believe something even though you yourself won’t actively help them or do not share their belief. English = “It’s up to you”, “Go ahead, I’m not going to stop you”, “Have it your way.”
  ```
- Only gives `Idiomatic English = `, no `English = `
  ```
  A gesture used by deaf and hearing Australians to mean something has just happened very quickly and often surprisingly. Idiomatic English = “just like that!”
  ```
- Single curly quotes which contain a curly quote for an apostrophe (could trip up logic which matches quotes)
  ```
  Used alone to alert someone that you have located something you are both discussing or looking for. English = ‘It’s here/there!’, ‘There/here it is!’.
  ```
- "And so on" should not be bolded (although as of 2025 it is)
  ```
  Used alone when you mean what you are about to say is easily understood or easy for anyone to agree with given the context, or that it is easy to understand or agree with what the person you have been talking to has said given the context. English = 'Well...', 'Well, there you are...', 'Well, there you go...', ‘Well, just so...’, 'That's all there is to it...', 'That's it...', 'Yeah...', 'Yep...', 'Yep, of course...', and so on.
  ```
- Threes sets of keywords, only the bits after `=` should be bolded
  ```
  A piece of clothing made of knitted wool, that covers the upper part of your body and your arms and does not open at the front. Australian English = jumper. British English = pullover. American English = sweater.
  ```


# Provenance

to upgrade to 1.18 I generated a new project using `mix igniter.new app_name --install ecto,phoenix,swoosh,credo,excellent_migrations,systemd,scrivener_ecto,ex_cldr,ex_cldr_lists,ecto_psql_extras,saxy,meeseeks,lexical_credo,ex_aws,ex_aws_s3,sweet_xml,req,oban --with phx.new`
with manual changes after that



# Checklist for if the right things are shown to the right people

- [ ] we settled on popular explanation not being shown on the basic view; can it be shown on the detail view?
- [ ] check every field in advanced search
- [ ] crosscheck advanced search fields with what's shown on detail view
- [ ] phonology fields specifically; which are okay to show?
- [ ] editorial fields (doubtful, problematic, problematic_video)
- [ ] check if we did mean to can the 'classes' page 
- [ ]
