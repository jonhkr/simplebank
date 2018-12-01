defmodule SimpleBank.Repo.Migrations.CreateTransaction do
  use Ecto.Migration

  def change do
    create table(:transaction) do
      add(:account_id, references(:account), null: false)
      add(:amount, :decimal, precision: 19, scale: 4, null: false)
      add(:type, :string, null: false)

      timestamps(updated_at: false)
    end
  end
end
