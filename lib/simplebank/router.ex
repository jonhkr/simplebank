defmodule SimpleBank.Router do
  use Plug.Router
  use Plug.ErrorHandler
  require Logger

  alias SimpleBank.{Users, Auth, Accounts, Withdrawals}

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
          details: encode_changeset_errors(changeset)
        }))
      {:error, _} -> send_resp(conn, 500, Jason.encode!(%{message: "Internal error"}))
    end
  end

  post "/v1/sessions" do
    params = conn.body_params
    username = params["username"]
    raw_password = params["raw_password"]

    case Auth.authenticate(username, raw_password) do
      {:ok, token} -> 
        send_resp(conn, 200, Jason.encode!(%{session_token: token}))
      {:error, _} -> 
        send_resp(conn, 401, Jason.encode!(%{message: "Invalid credentials"}))
    end
  end

  get "/v1/accounts" do
    case check_authorization(conn) do
      {:ok, user} ->
        accounts = Accounts.get_user_accounts(user.id)
        send_resp(conn, 200, Jason.encode!(accounts))
      {:error, _} ->
        send_resp(conn, 401, Jason.encode!(%{message: "Unauthorized"}))
    end
  end

  post "/v1/withdrawals" do
    case check_authorization(conn) do
      {:ok, user} ->
        account = Accounts.get_user_account(user.id, "BRL")
        case Withdrawals.create_withdrawal(account.id, conn.body_params["amount"]) do
          {:ok, wd} -> send_resp(conn, 200, Jason.encode!(wd))
          {:error, %Ecto.Changeset{} = changeset} ->
            send_resp(conn, 400, Jason.encode!(%{
              details: encode_changeset_errors(changeset)
            }))
          {:error, %SimpleBank.Error{message: message}} ->
            send_resp(conn, 422, Jason.encode!(%{message: message}))
          {:error, _} ->
            send_resp(conn, 500, Jason.encode!(%{message: "Internal error"}))
        end
      {:error, _} ->
        send_resp(conn, 401, Jason.encode!(%{message: "Unauthorized"}))
    end
  end

  defp check_authorization(%Plug.Conn{} = conn) do
    conn
    |> get_req_header("authorization")
    |> check_authorization() 
  end
  defp check_authorization([]), do: {:error, :unathorized}
  defp check_authorization([h | _]) do
    if String.starts_with?(h, "Bearer ") do
      String.slice(h, 7..-1)
      |> Auth.validate_and_get_user()
    else
      {:error, :unauthorized}
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