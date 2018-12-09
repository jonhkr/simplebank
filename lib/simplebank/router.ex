defmodule SimpleBank.Router do
  use Plug.Router
  use Plug.ErrorHandler
  require Logger

  alias SimpleBank.{
    AuthPlug,
    Users,
    Auth,
    Accounts,
    Withdrawals,
    Transfers
  }

  plug Plug.Logger
  plug Plug.RequestId
  plug Plug.Parsers, parsers: [:json], json_decoder: Jason

  plug :match

  plug AuthPlug

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
    email = params["email"]

    Users.create_user(name, username, raw_password, email)
    |> encode_resp()
    |> send_resp(conn)
  end

  post "/v1/sessions" do
    params = conn.body_params
    username = params["username"]
    raw_password = params["raw_password"]

    case Auth.authenticate(username, raw_password) do
      {:ok, token} -> 
        send_resp(conn, 200, Jason.encode!(%{session_token: token}))
      {:error, _} -> 
        send_resp(conn, 401, Jason.encode!(%{message: "invalid credentials"}))
    end
  end

  get "/v1/accounts", private: %{auth: true} do
    user = conn.assigns[:user]
    accounts = Accounts.get_user_accounts(user.id)

    send_resp(conn, 200, Jason.encode!(accounts))
  end

  post "/v1/withdrawals", private: %{auth: true} do
    user = conn.assigns[:user]
    account = Accounts.get_user_account(user.id, "BRL")
    amount = conn.body_params["amount"]

    Withdrawals.create_withdrawal(account.id, amount)
    |> encode_resp()
    |> send_resp(conn)
  end

  post "/v1/transfers", private: %{auth: true} do
    user = conn.assigns[:user]
    account = Accounts.get_user_account(user.id, "BRL")
    amount = conn.body_params["amount"]
    destination = conn.body_params["destination"]

    Transfers.send_money(account.id, amount, destination)
    |> encode_resp()
    |> send_resp(conn)
  end

  get "/v1/reports", private: %{auth: true} do
    user = conn.assigns[:user]
    account = Accounts.get_user_account(user.id, "BRL")
    type = conn.params["type"]
    start_date = conn.params["start_date"]
    end_date = conn.params["end_date"]

    Accounts.generate_report(type, account.id, start_date, end_date)
    |> encode_resp()
    |> send_resp(conn)
  end

  match _ do
    send_resp(conn, 404, Jason.encode!(%{message: "not found"}))
  end

  defp encode_resp({:ok, data}) do
    {200, Jason.encode!(data)}
  end
  defp encode_resp({:error, %Ecto.Changeset{} = changeset}) do
    {400, Jason.encode!(%{details: encode_changeset_errors(changeset)})}
  end
  defp encode_resp({:error, %SimpleBank.Error{message: message}}) do
    {422, Jason.encode!(%{message: message})}
  end
  defp encode_resp({:error, _}) do
    {500, Jason.encode!(%{message: "internal error"})}
  end

  defp send_resp({status_code, resp_body}, conn) do
    send_resp(conn, status_code, resp_body)
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
    Logger.error "Something went wrong. #{inspect reason}"

    error_code = reason.__struct__
      |> Module.split
      |> List.last

    send_resp(conn, conn.status, Jason.encode!(%{
      code: error_code,
      message: Exception.message(reason)
    }))
  end
end