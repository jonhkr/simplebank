defmodule TransferTest do
  use ExUnit.Case

  import Decimal

  alias SimpleBank.{Repo, Users, Accounts, Transfers}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "send money" do
    name = "Jonas Trevisan"
    password = "jonast"
    email = "jonast@jonast.com"

    {:ok, user1} = Users.create_user(name, "user1", password, email)
    {:ok, user2} = Users.create_user(name, "user2", password, email)

    [source] = Accounts.get_user_accounts(user1.id)
    [destination] = Accounts.get_user_accounts(user2.id)

    {:ok, transfer} = Transfers.send_money(source.id, 100, destination.iban)

    assert cmp(transfer.amount, 100) == :eq
    assert transfer.transaction_id != nil
    assert transfer.account_id == source.id

    updated_source = Accounts.get_account(source.id)
    updated_destination = Accounts.get_account(destination.id)

    assert cmp(updated_source.balance, sub(source.balance, transfer.amount)) == :eq
    assert cmp(updated_destination.balance, add(destination.balance, transfer.amount)) == :eq
  end

  test "send money without balance" do
    name = "Jonas Trevisan"
    password = "jonast"
    email = "jonast@jonast.com"

    {:ok, user1} = Users.create_user(name, "user1", password, email)
    {:ok, user2} = Users.create_user(name, "user2", password, email)

    [source] = Accounts.get_user_accounts(user1.id)
    [destination] = Accounts.get_user_accounts(user2.id)

    {:error, error} = Transfers.send_money(source.id, 1100, destination.iban)

    assert %SimpleBank.Error{message: "insufficient funds"} = error
  end
end