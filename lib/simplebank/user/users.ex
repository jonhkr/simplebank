defmodule SimpleBank.Users do
  
  alias SimpleBank.{Repo, User, UserSession}

  def create_user(name, username, raw_password) do
    %User{}
    |> User.changeset(%{name: name, username: username, raw_password: raw_password})
    |> Repo.insert()
  end

  def create_session(username, raw_password) do
    user = Repo.get_by(User, username: username)

    case User.password_matches(user, raw_password) do
      false -> {:error, "invalid credentials"}
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

  defp create_session(user) do
    %UserSession{}
    |> UserSession.changeset(%{user_id: user.id})
    |> Repo.insert()
  end
end