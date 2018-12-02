defmodule WithdrawalsApiTest do
  use ExUnit.Case
  use Plug.Test

  alias SimpleBank.{Repo, Router, Auth, Accounts}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  @opts Router.init([])

  test "create withdrawal" do
    name = "Jonas Trevisan"
    username = "jonast"
    password = "jonast"
    email = "jonast@jonast.com"

    user_params = %{name: name, username: username, raw_password: password, email: email}

    conn =
      conn(:post, "/v1/users", Jason.encode!(user_params))
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    assert conn.status == 200

    %{"id" => user_id} = Jason.decode!(conn.resp_body)

    {:ok, auth_token} = Auth.authenticate(username, password)

    req_body = %{amount: 100}

    conn =
      conn(:post, "/v1/withdrawals", Jason.encode!(req_body))
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Bearer " <> auth_token)
      |> Router.call(@opts)

    assert conn.status == 200

    assert %{
      "account_id" => account_id,
      "amount" => "100"} = Jason.decode!(conn.resp_body)

    account = Accounts.get_user_account(user_id, "BRL")

    assert account.id == account_id
    assert Decimal.cmp(account.balance, 900) == :eq
  end

  test "insufficient funds for withdrawal" do
    name = "Jonas Trevisan"
    username = "jonast"
    password = "jonast"
    email = "jonast@jonast.com"

    user_params = %{name: name, username: username, raw_password: password, email: email}

    conn =
      conn(:post, "/v1/users", Jason.encode!(user_params))
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    assert conn.status == 200

    {:ok, auth_token} = Auth.authenticate(username, password)

    req_body = %{amount: 1100}

    conn =
      conn(:post, "/v1/withdrawals", Jason.encode!(req_body))
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Bearer " <> auth_token)
      |> Router.call(@opts)

    assert conn.status == 422

    assert %{"message" => "insufficient funds"} = Jason.decode!(conn.resp_body)
  end
end