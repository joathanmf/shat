defmodule Shat.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ShatWeb.Telemetry,
      Shat.Repo,
      {DNSCluster, query: Application.get_env(:shat, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Shat.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Shat.Finch},
      # Start a worker by calling: Shat.Worker.start_link(arg)
      # {Shat.Worker, arg},
      # Start to serve requests, typically the last entry
      ShatWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Shat.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ShatWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
