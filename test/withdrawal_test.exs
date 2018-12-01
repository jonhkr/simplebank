defmodule WithdrawalTest do
  use ExUnit.Case

  alias SimpleBank.{Repo, Users, Accounts, Withdrawals}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "create withdrawal" do
    name = "Jonas Trevisan"
    username = "jonast"
    password = "jonast"

    {:ok, user} = Users.create_user(name, username, password)

    [account] = Accounts.get_user_accounts(user.id)

    {:ok, wd} = Withdrawals.create_withdrawal(account.id, 100)

    assert Decimal.cmp(wd.amount, 100) == :eq
    assert wd.transaction_id != nil
    assert wd.account_id == account.id

    account = Accounts.get_account(account.id)

    assert Decimal.cmp(account.balance, 900) == :eq
  end
end
