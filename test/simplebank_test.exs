defmodule SimpleBankTest do
  use ExUnit.Case
  doctest SimpleBank

  test "greets the world" do
    assert SimpleBank.hello() == :world
  end
end
