defmodule Signbank.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SignbankWeb.Telemetry,
      Signbank.Repo,
      {DNSCluster, query: Application.get_env(:signbank, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Signbank.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Signbank.Finch},
      # Start a worker by calling: Signbank.Worker.start_link(arg)
      # {Signbank.Worker, arg},
      # Start to serve requests, typically the last entry
      :systemd.ready(),
      SignbankWeb.Endpoint
    ]

    choose_logger()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Signbank.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SignbankWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def choose_logger do
    case Application.get_env(:signbank, :logger, :console) do
      :systemd ->
        :logger.add_handlers(:systemd)
        Logger.remove_backend(:console)

      :console ->
        nil
    end
  end
end
