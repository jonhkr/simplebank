defmodule SimpleBank.Auth do
  use Joken.Config

  alias SimpleBank.Users
  
  @impl true
  def token_config do
    default_claims(skip: [:aud, :iss])
    |> add_claim("iss", "SimpleBank")
  end

  def authenticate(username, raw_password) do
    case Users.create_session(username, raw_password) do
      {:ok, session} ->
        {:ok, generate_and_sign!(%{
          user_id: session.user_id,
          sub: session.id
        })}
      error -> error
    end
  end

  def validate_and_get_user(session_token) do
    case verify_and_validate(session_token) do
      {:ok, claims} -> 
        case Users.valid_session(claims["sub"]) do
          true -> {:ok, Users.get_user(claims["user_id"])}
          false -> {:error, :invalid_token}
        end
      error -> {:error, :invalid_token}
    end
  end

  def revoke(session_token) do
    case verify_and_validate(session_token) do
      {:ok, claims} -> Users.revoke_session(claims["sub"])
      {:error, error} -> error
    end
  end
end
