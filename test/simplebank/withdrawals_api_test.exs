defmodule SimpleBank.WithdrawalsApiTest do
  use SimpleBank.TestCase

  @opts Router.init([])

  test "POST /v1/withdrawals is protected" do
    conn =
      conn(:post, "/v1/withdrawals")
      |> Router.call(@opts)

    assert conn.status == 401
    assert %{"message" => "unauthorized"} == Jason.decode!(conn.resp_body)
  end

  test "create withdrawal" do
    {:ok, %User{id: user_id}, session_token} = build_user_session_token()

    req_body = %{amount: 100}

    conn =
      conn(:post, "/v1/withdrawals", Jason.encode!(req_body))
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Bearer " <> session_token)
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
    {:ok, _user, session_token} = build_user_session_token()

    req_body = %{amount: 1100}

    conn =
      conn(:post, "/v1/withdrawals", Jason.encode!(req_body))
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Bearer " <> session_token)
      |> Router.call(@opts)

    assert conn.status == 422

    assert %{"message" => "insufficient funds"} = Jason.decode!(conn.resp_body)
  end
end