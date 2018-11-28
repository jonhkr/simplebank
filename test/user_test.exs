defmodule UserTest do
  use ExUnit.Case

  alias SimpleBank.Repo

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "create user" do
    assert true
  end
end
