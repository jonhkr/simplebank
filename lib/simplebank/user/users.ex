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

  defp create_session(user) do
    %UserSession{}
    |> UserSession.changeset(%{user_id: user.id})
    |> Repo.insert()
  end
end