defmodule SimpleBank.TransferTest do
  use SimpleBank.TestCase

  import Decimal

  test "send money" do
    {source, destination} = create_accounts()

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
    {source, destination} = create_accounts()

    {:error, error} = Transfers.send_money(source.id, 1100, destination.iban)

    assert %SimpleBank.Error{message: "insufficient funds"} = error
  end

  defp create_accounts() do
    {:ok, origin_user, _username, _password} = create_user()
    {:ok, destination_user, _username, _password} = create_user()

    source = Accounts.get_user_account(origin_user.id, "BRL")
    destination = Accounts.get_user_account(destination_user.id, "BRL")

    {source, destination}
  end
end