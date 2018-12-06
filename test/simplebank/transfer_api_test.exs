defmodule SimpleBank.TransferApiTest do
  use SimpleBank.TestCase

  @opts Router.init([])

  test "POST /v1/transfers is protected" do
    conn =
      conn(:post, "/v1/transfers")
      |> Router.call(@opts)

    assert conn.status == 401
    assert %{"message" => "unauthorized"} == Jason.decode!(conn.resp_body)
  end

  test "create transfer" do
    {:ok, origin_user, auth_token} = build_user_session_token()
    {:ok, destination_user, _username, _password} = create_user()

    destination_account = Accounts.get_user_account(destination_user.id, "BRL")

    req_body = %{amount: 100, destination: destination_account.iban}
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

    source_account = Accounts.get_user_account(origin_user.id, "BRL")

    assert source_account.id == account_id
    assert destination_account.iban == destination_iban
    assert Decimal.cmp(source_account.balance, 900) == :eq

    destination_account = Accounts.get_user_account(destination_user.id, "BRL")

    assert Decimal.cmp(destination_account.balance, 1100) == :eq
  end

  test "insufficient funds for withdrawal" do
    {:ok, origin_user, auth_token} = build_user_session_token()
    {:ok, destination_user, _username, _password} = create_user()

    destination_account = Accounts.get_user_account(destination_user.id, "BRL")

    req_body = %{amount: 1100, destination: destination_account.iban}
    conn =
      conn(:post, "/v1/transfers", Jason.encode!(req_body))
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Bearer " <> auth_token)
      |> Router.call(@opts)

    assert conn.status == 422

    assert %{"message" => "insufficient funds"} = Jason.decode!(conn.resp_body)

    source_account = Accounts.get_user_account(origin_user.id, "BRL")

    assert Decimal.cmp(source_account.balance, 1000) == :eq
  end
end