defmodule SimpleBank.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:user) do
      add(:name, :string)
      add(:username, :string, null: false)
      add(:password_hash, :string, null: false)

      timestamps()
    end

    create(unique_index(:user, [:username], name: :idx_unique_user_username))
  end
end
