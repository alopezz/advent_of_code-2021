defmodule DumboOctopus.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      DumboOctopusWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: DumboOctopus.PubSub},
      # Start the Endpoint (http/https)
      DumboOctopusWeb.Endpoint
      # Start a worker by calling: DumboOctopus.Worker.start_link(arg)
      # {DumboOctopus.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DumboOctopus.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DumboOctopusWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
