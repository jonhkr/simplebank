defmodule SimpleBank.Router do
  use Plug.Router
  use Plug.ErrorHandler
  require Logger

  plug Plug.Logger
  plug Plug.RequestId
  plug Plug.Parsers, parsers: [:json], json_decoder: Jason

  plug :match
  plug :dispatch

  get "/_health" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{status: "ok"}))
  end

  def handle_errors(conn, %{kind: _kind, reason: reason, stack: _stack}) do
    Logger.info "Something went wrong. #{inspect reason}"

    error_code = reason.__struct__
      |> Module.split
      |> List.last

    send_resp(conn, conn.status, Jason.encode!(%{
      code: error_code,
      message: Exception.message(reason)
    }))

  end
end