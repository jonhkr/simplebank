defmodule SimpleBank.Repo.Migrations.CreateAccount do
  use Ecto.Migration

  def change do
    create table(:account) do
      add(:user_id, references(:user), null: false)
      add(:iban, :string, null: false)
      add(:currency, :string, null: false)

      timestamps()
    end
  end
end
