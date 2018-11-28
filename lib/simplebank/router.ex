defmodule SimpleBank.Router do
  use Plug.Router
  use Plug.ErrorHandler
  require Logger

  alias SimpleBank.{Users}

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

  post "/v1/users" do
    params = conn.body_params
    name = params["name"]
    username = params["username"]
    raw_password = params["raw_password"]

    case Users.create_user(name, username, raw_password) do
      {:ok, user} -> send_resp(conn, 200, Jason.encode!(user))
      {:error, %Ecto.Changeset{} = changeset} -> 
        send_resp(conn, 400, Jason.encode!(%{
          "details" => encode_changeset_errors(changeset)
        }))
    end
  end

  defp encode_changeset_errors(changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end) 
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