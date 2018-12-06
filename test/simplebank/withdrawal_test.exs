defmodule SimpleBank.WithdrawalTest do
  use SimpleBank.TestCase

  test "create withdrawal" do
    {:ok, user, _username, _password} = create_user()

    account = Accounts.get_user_account(user.id, "BRL")

    {:ok, wd} = Withdrawals.create_withdrawal(account.id, 100)

    assert Decimal.cmp(wd.amount, 100) == :eq
    assert wd.transaction_id != nil
    assert wd.account_id == account.id

    updated_account = Accounts.get_account(account.id)

    assert Decimal.cmp(updated_account.balance, Decimal.sub(account.balance, wd.amount)) == :eq
  end

  test "create withdrawal blank amount" do
    {:ok, user, _username, _password} = create_user()

    account = Accounts.get_user_account(user.id, "BRL")

    {:error, changeset} = Withdrawals.create_withdrawal(account.id, nil)

    errors = changeset.errors

    assert [amount: {"can't be blank", [validation: :required]}] = errors

    updated_account = Accounts.get_account(account.id)

    assert Decimal.cmp(account.balance, updated_account.balance) == :eq
  end

  test "create withdrawal negative amount" do
    {:ok, user, _username, _password} = create_user()

    account = Accounts.get_user_account(user.id, "BRL")

    {:error, changeset} = Withdrawals.create_withdrawal(account.id, -100)

    errors = changeset.errors

    assert [
      amount: {"must be greater than %{number}",
      [validation: :number, kind: :greater_than, number: 0]
    }] = errors

    updated_account = Accounts.get_account(account.id)

    assert Decimal.cmp(account.balance, updated_account.balance) == :eq
  end
end
