defmodule SimpleBank.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  require Logger

  def start(_type, _args) do
    :ok = SimpleBank.Statix.connect()

    # List all child processes to be supervised
    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: SimpleBank.Router,
        options: [port: server_port()]),
      {SimpleBank.Repo, []}
    ]

    Logger.info("Application starting. Server port: #{server_port()}")

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SimpleBank.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp server_port(), do: Application.get_env(:simplebank, :port, 3000)
end
