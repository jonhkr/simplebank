defmodule SimpleBank.Users do
  
  alias SimpleBank.{Repo, User, UserSession, Accounts}

  def create_user(name, username, raw_password) do
    changeset = User.changeset(%User{}, %{
      name: name,
      username: username,
      raw_password: raw_password
    })

    create_user(changeset)
  end

  def get_user(user_id) do
    Repo.get(User, user_id)
  end

  def create_session(nil, _), do: {:error, :invalid_credentials}
  def create_session(_, nil), do: {:error, :invalid_credentials}
  def create_session(username, raw_password) do
    user = Repo.get_by(User, username: username)

    case User.password_matches(user, raw_password) do
      false -> {:error, :invalid_credentials}
      _ -> create_session(user)
    end
  end

  def revoke_session(session_id) do
    case get_session(session_id) do
      nil -> false
      session -> 
        session
        |> UserSession.changeset(%{revoke: true})
        |> Repo.update()
    end
  end

  def get_session(session_id) do
    Repo.get(UserSession, session_id)
  end

  def valid_session(session_id) do
    case get_session(session_id) do
      nil -> false
      %UserSession{revoked_at: nil} -> true
      _ -> false
    end
  end

  defp create_user(%Ecto.Changeset{valid?: false} = changeset), do: {:error, changeset}
  defp create_user(%Ecto.Changeset{valid?: true} = changeset) do
    Repo.transaction fn ->
      result = Repo.insert(changeset)
      |> create_account(1_000, "BRL")

      case result do
        {:ok, _account, user} -> user
        {:error, error} -> Repo.rollback(error)
      end
    end
  end

  defp create_account({:error, _} = error, _initial_deposit, _currency), do: error
  defp create_account({:ok, user}, initial_deposit, currency) do
    case Accounts.create_account(user, initial_deposit, currency) do
      {:ok, account} -> {:ok, account, user}
      error -> error
    end
  end

  defp create_session(user) do
    %UserSession{}
    |> UserSession.changeset(%{user_id: user.id})
    |> Repo.insert()
  end
end