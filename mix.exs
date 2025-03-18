defmodule Signbank.MixProject do
  use Mix.Project

  def project do
    [
      app: :signbank,
      version: "0.7.0",
      elixir: "~> 1.17",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      releases: [
        signbank: [
          steps: [:assemble, :tar]
        ]
      ],
      dialyzer: [flags: [:error_handling, :underspecs]]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Signbank.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # Basic Phoenix dependancies
      {:bcrypt_elixir, "~> 3.0"},
      {:phoenix, "~> 1.7.11"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.12"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.2"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.0"},
      {:floki, ">= 0.30.0"},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      # Email sending
      {:swoosh, "~> 1.5"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.2"},
      # Static code analysis
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      # Static code analysis
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      # Detect unsafe migrations
      {:excellent_migrations, "~> 0.1", only: [:dev, :test], runtime: false},
      # Run prod using systemd
      {:systemd, "~> 0.6"},
      # SCSS compilation
      {:dart_sass, "~> 0.6", runtime: Mix.env() == :dev},
      # Pagination
      {:scrivener_ecto, "~> 3.1"},
      # Locale data (for localisation)
      {:ex_cldr, "~> 2.40"},
      {:ex_cldr_lists, "~> 2.11"},
      # Icon components
      {:heroicons, "~> 0.5.5"},
      # Enables monitoring Ecto from the dashboard
      {:ecto_psql_extras, "~> 0.7"},
      {:csv, "~> 3.2"},
      # XML parsing
      {:saxy, "~> 1.5"},
      {:meeseeks, "~> 0.17.0"},
      # Formats Ecto logs nicely in :dev
      {:ecto_dev_logger, "~> 0.14"},
      {:lexical_credo, "~> 0.5.0", only: [:dev, :test]}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["esbuild.install --if-missing"],
      "assets.build": ["esbuild signbank"],
      "assets.deploy": [
        "assets.setup",
        "esbuild signbank --minify",
        "sass default --no-source-map --style=compressed",
        "phx.digest"
      ]
    ]
  end
end
