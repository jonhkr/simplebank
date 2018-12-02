defmodule TransferApiTest do
  use ExUnit.Case
  use Plug.Test

  alias SimpleBank.{Repo, Router, Auth, Accounts, Users}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  @opts Router.init([])

  test "create transfer" do
    name = "Jonas Trevisan"
    password = "jonast"
    email = "jonast@jonast.com"

    {:ok, user1} = Users.create_user(name, "user1", password, email)
    {:ok, user2} = Users.create_user(name, "user2", password, email)

    [destination] = Accounts.get_user_accounts(user2.id)

    {:ok, auth_token} = Auth.authenticate("user1", password)

    req_body = %{amount: 100, destination: destination.iban}
    conn =
      conn(:post, "/v1/transfers", Jason.encode!(req_body))
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Bearer " <> auth_token)
      |> Router.call(@opts)

    assert conn.status == 200

    assert %{
      "account_id" => account_id,
      "amount" => "100",
      "direction" => "out",
      "destination" => destination_iban} = Jason.decode!(conn.resp_body)

    source_account = Accounts.get_user_account(user1.id, "BRL")

    assert source_account.id == account_id
    assert destination.iban == destination_iban
    assert Decimal.cmp(source_account.balance, 900) == :eq

    destination_account = Accounts.get_user_account(user2.id, "BRL")

    assert Decimal.cmp(destination_account.balance, 1100) == :eq
  end

  test "insufficient funds for withdrawal" do
    name = "Jonas Trevisan"
    password = "jonast"
    email = "jonast@jonast.com"

    {:ok, user1} = Users.create_user(name, "user1", password, email)
    {:ok, user2} = Users.create_user(name, "user2", password, email)

    [destination] = Accounts.get_user_accounts(user2.id)

    {:ok, auth_token} = Auth.authenticate("user1", password)

    req_body = %{amount: 1100, destination: destination.iban}
    conn =
      conn(:post, "/v1/transfers", Jason.encode!(req_body))
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Bearer " <> auth_token)
      |> Router.call(@opts)

    assert conn.status == 422

    assert %{"message" => "insufficient funds"} = Jason.decode!(conn.resp_body)

    source_account = Accounts.get_user_account(user1.id, "BRL")

    assert Decimal.cmp(source_account.balance, 1000) == :eq
  end
end