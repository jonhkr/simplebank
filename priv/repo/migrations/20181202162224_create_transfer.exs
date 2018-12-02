defmodule SimpleBank.Repo.Migrations.CreateTransfer do
  use Ecto.Migration

  def change do
    create table(:transfer) do
      add(:account_id, references(:account), null: false)
      add(:transaction_id, references(:transaction), null: false)
      add(:amount, :decimal, precision: 19, scale: 4, null: false)
      add(:direction, :string, null: false)
      add(:source, :string)
      add(:destination, :string)

      timestamps(updated_at: false)
    end
  end
end
