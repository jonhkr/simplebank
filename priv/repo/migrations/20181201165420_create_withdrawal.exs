defmodule SimpleBank.Repo.Migrations.CreateWithdrawal do
  use Ecto.Migration

  def change do
    create table(:withdrawal) do
      add(:account_id, references(:account), null: false)
      add(:transaction_id, references(:transaction), null: false)
      add(:amount, :decimal, precision: 19, scale: 4, null: false)

      timestamps(updated_at: false)
    end
  end
end
