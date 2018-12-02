defmodule AccountTest do
  use ExUnit.Case

  alias SimpleBank.{Repo, Users, Accounts}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "create account on user registration" do
    name = "Jonas Trevisan"
    username = "jonast"
    password = "jonast"
    email = "jonast@jonast.com"

    {:ok, user} = Users.create_user(name, username, password, email)

    [account] = Accounts.get_user_accounts(user.id)

    assert account.user_id == user.id
    assert account.currency == "BRL"
    assert account.iban != nil
    assert Decimal.equal?(account.balance, 1_000)
  end
end
