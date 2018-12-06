defmodule SimpleBank.TestCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Plug.Test

      import unquote(__MODULE__)

      alias SimpleBank.{
        Repo,
        Router,
        Error,
        Auth,
        User,
        Users,
        Accounts,
        Transfers,
        Withdrawals,
      }
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(SimpleBank.Repo)
    
    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(SimpleBank.Repo, {:shared, self()})
    end
    
    :ok
  end

  def create_user() do
    username = Ecto.UUID.generate()
    password = Ecto.UUID.generate()

    {:ok, user} = SimpleBank.Users.create_user("Test User", username, password, "test@example.com")

    {:ok, user, username, password}
  end

  def build_user_session_token() do
    {:ok, user, username, password} = create_user()

    {:ok, session_token} = SimpleBank.Auth.authenticate(username, password)

    {:ok, user, session_token}
  end
end