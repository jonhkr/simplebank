defmodule AccountApiTest do
  use ExUnit.Case
  use Plug.Test

  alias SimpleBank.{Repo, Router, Auth, Accounts}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  @opts Router.init([])

  test "get user accounts" do
    name = "Jonas Trevisan"
    username = "jonast"
    password = "jonast"

    req_body = %{name: name, username: username, raw_password: password}

    conn =
      conn(:post, "/v1/users", Jason.encode!(req_body))
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    assert conn.status == 200

    %{"id" => user_id} = Jason.decode!(conn.resp_body)

    {:ok, auth_token} = Auth.authenticate(username, password)

    conn =
      conn(:get, "/v1/accounts")
      |> put_req_header("authorization", "Bearer " <> auth_token)
      |> Router.call(@opts)

    assert conn.status == 200

    assert [%{
      "id" => account_id,
      "user_id" => ^user_id,
      "iban" => iban,
      "balance" => "1000.0000",
      "currency" => "BRL"}] = Jason.decode!(conn.resp_body)

    [account] = Accounts.get_user_accounts(user_id)

    assert account_id == account.id
    assert iban == account.iban
  end
end