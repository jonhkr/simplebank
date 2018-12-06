defmodule SimpleBank.AccountApiTest do
  use SimpleBank.TestCase

  @opts Router.init([])

  test "GET /v1/accounts is protected" do
    conn =
      conn(:get, "/v1/accounts")
      |> Router.call(@opts)

    assert conn.status == 401
    assert %{"message" => "unauthorized"} == Jason.decode!(conn.resp_body)
  end

  test "get user accounts" do
    {:ok, %User{id: user_id}, session_token} = build_user_session_token()

    conn =
      conn(:get, "/v1/accounts")
      |> put_req_header("authorization", "Bearer " <> session_token)
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

  test "generate summary report" do
    {:ok, _user, session_token} = build_user_session_token()

    today = Date.to_iso8601(Date.utc_today())

    conn = request_report(session_token, %{"type" => "summary", "start_date" => today, "end_date" => today})

    assert conn.status == 200
    assert %{
      "credit_amount" => "1000.0000",
      "credit_count" => 1,
      "debit_amount" => "0",
      "debit_count" => 0,
      "end_date" => today,
      "start_date" => today,
      "transaction_count" => 1
    } = Jason.decode!(conn.resp_body)
  end

  test "generate summary invalid request" do
    {:ok, _user, session_token} = build_user_session_token()

    today = Date.to_iso8601(Date.utc_today())

    conn = request_report(session_token, %{"type" => "summary", "end_date" => today})
    assert conn.status == 422
    assert %{"message" => "start date is required"} = Jason.decode!(conn.resp_body)

    conn = request_report(session_token, %{"type" => "summary", "start_date" => today})
    assert conn.status == 422
    assert %{"message" => "end date is required"} = Jason.decode!(conn.resp_body)

    conn = request_report(session_token, %{"type" => "summary", "start_date" => "foo", "end_date" => today})
    assert conn.status == 422
    assert %{"message" => "invalid date format"} = Jason.decode!(conn.resp_body)

    conn = request_report(session_token, %{"type" => "foo", "start_date" => today, "end_date" => today})
    assert conn.status == 422
    assert %{"message" => "unknown report type foo"} = Jason.decode!(conn.resp_body)
  end

  defp request_report(session_token, params) do
    conn(:get, "/v1/reports", params)
    |> put_req_header("authorization", "Bearer " <> session_token)
    |> Router.call(@opts)
  end
end