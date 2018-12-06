defmodule SimpleBank.AccountTest do
  use SimpleBank.TestCase

  test "create account on user registration" do
    {:ok, user, _username, _password} = create_user()

    [account] = Accounts.get_user_accounts(user.id)

    assert account.user_id == user.id
    assert account.currency == "BRL"
    assert account.iban != nil
    assert Decimal.equal?(account.balance, 1_000)
  end

  test "get summary report" do
    {:ok, user, _username, _password} = create_user()
    
    [account] = Accounts.get_user_accounts(user.id)

    Accounts.debit_account(account.id, Decimal.new(100), "withdrawal")

    {:ok, report} = Accounts.generate_report("summary", account.id, "2018-01-01", "2018-12-31")

    assert report.transaction_count == 2
    assert report.debit_count == 1
    assert report.credit_count == 1
    assert Decimal.cmp(report.debit_amount, 100) == :eq
    assert Decimal.cmp(report.credit_amount, 1_000) == :eq
    assert report.start_date == ~D[2018-01-01]
    assert report.end_date == ~D[2018-12-31]
  end

  test "get summary report invalid date" do
    assert {:error, %Error{message: "invalid date format"}} =
      Accounts.generate_report("summary", -1, "2018-01", "2018-12-31")

    assert {:error, %Error{message: "invalid date format"}} =
      Accounts.generate_report("summary", -1, "2018-01-01", "2018-31")

    assert {:error, %Error{message: "invalid date"}} =
      Accounts.generate_report("summary", -1, "2018-35-01", "2018-01-31")

    assert {:error, %Error{message: "invalid date"}} =
      Accounts.generate_report("summary", -1, "2018-01-01", "2018-35-31")

    assert {:error, %Error{message: "start date should be before end date"}} =
      Accounts.generate_report("summary", -1, "2019-01-01", "2018-12-31")
  end
end
