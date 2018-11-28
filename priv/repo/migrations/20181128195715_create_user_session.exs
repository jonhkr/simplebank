defmodule SimpleBank.Repo.Migrations.CreateUserSession do
  use Ecto.Migration

  def change do
    create table(:user_session) do
      add(:user_id, references(:user))
      add(:revoked_at, :utc_datetime_usec)

      timestamps()
    end
  end
end
