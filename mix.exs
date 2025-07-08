defmodule Signbank.MixProject do
  use Mix.Project

  def project do
    [
      app: :signbank,
      version: "0.8.0",
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      consolidate_protocols: Mix.env() != :dev,
      aliases: aliases(),
      deps: deps(),
      releases: [
        signbank: [
          steps: [:assemble, :tar]
        ]
      ],
      dialyzer: [flags: [:error_handling, :underspecs]],
      listeners: [Phoenix.CodeReloader]
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
      {:phoenix, "~> 1.8.0-rc.3", override: true},
      {:phoenix_ecto, "~> 4.5"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.0.9"},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.9", runtime: Mix.env() == :dev},
      {:ecto, "~> 3.0"},
      {:ecto_sql, "~> 3.10"},
      {:ecto_psql_extras, "~> 0.8"},

      # Pagination
      {:scrivener_ecto, "~> 3.0"},

      # Static code analysis and linting
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:lexical_credo, "~> 0.5", only: [:dev, :test]},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:recode, "~> 0.7", only: :dev},

      # Detect unsafe migrations
      {:excellent_migrations, "~> 0.1", only: [:dev, :test], runtime: false},

      # for localisation
      {:ex_cldr_lists, "~> 2.0"},
      {:ex_cldr, "~> 2.0"},
      {:gettext, "~> 0.26"},

      # XML parsing
      {:meeseeks, "~> 0.18"},
      {:saxy, "~> 1.0"},
      {:sweet_xml, "~> 0.7"},
      {:bandit, "~> 1.5"},
      {:bcrypt_elixir, "~> 3.0"},
      {:csv, "~> 3.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:ecto_dev_logger, "~> 0.14"},
      {:ex_aws_s3, "~> 2.0"},
      {:ex_aws, "~> 2.0"},
      {:floki, ">= 0.30.0", only: :test},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:jason, "~> 1.2"},
      {:oban, "~> 2.0"},
      {:oban_web, "~> 2.11"},
      {:req, "~> 0.5"},
      {:swoosh, "~> 1.0"},
      {:systemd, "~> 0.6"},
      {:tailwind, "~> 0.3", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:kino_component, "~> 0.2"}
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
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind signbank", "esbuild signbank"],
      "assets.deploy": [
        "assets.setup",
        "tailwind signbank --minify",
        "esbuild signbank --minify",
        "phx.digest"
      ]
    ]
  end
end
