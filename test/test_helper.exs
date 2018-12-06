ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(SimpleBank.Repo, :manual)

Code.require_file("test_case.exs", __DIR__)