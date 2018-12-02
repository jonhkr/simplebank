defmodule SimpleBank.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Comeonin.Bcrypt, only: [hashpwsalt: 1, checkpw: 2]

  @derive {Jason.Encoder, only: [:id, :name, :username, :inserted_at]}
  schema "user" do
    field :name
    field :username
    field :email
    field :raw_password, :string, virtual: true
    field :password_hash

    timestamps()
  end

  # Taken from https://gist.github.com/daemonfire300/b6705a9ce103a8bf3f70c755350ac683
  @mail_regex ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/
  @required_fields [:name, :username, :raw_password, :email]

  def changeset(user, params \\ :empty) do
    user
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> validate_length(:username, min: 4, max: 100)
    |> validate_length(:raw_password, min: 6)
    |> validate_format(:email, @mail_regex)
    |> unique_constraint(:username, name: :idx_unique_user_username)
    |> hash_password
  end

  def password_matches(user, raw_password) do
    case user do
      nil -> false
      _ -> checkpw(raw_password, user.password_hash)
    end
  end

  defp hash_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{raw_password: raw_password}} -> 
        changeset
        |> put_change(:password_hash, hashpwsalt(raw_password))
        |> put_change(:raw_password, nil)
      _ -> changeset
    end
  end
end