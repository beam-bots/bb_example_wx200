defmodule BB.Example.WX200.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BB.Example.WX200Web.Telemetry,
      {DNSCluster, query: Application.get_env(:bb_example_wx200, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: BB.Example.WX200.PubSub},
      # Start a worker by calling: BB.Example.WX200.Worker.start_link(arg)
      # {BB.Example.WX200.Worker, arg},
      # Start to serve requests, typically the last entry
      BB.Example.WX200Web.Endpoint,
      {BB.Example.WX200.Robot, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BB.Example.WX200.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BB.Example.WX200Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
