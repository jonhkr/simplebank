defmodule SimpleBank.Repo.Migrations.AddIndexToTransactionInsertedAt do
  use Ecto.Migration

  def change do
    create(index(:transaction, [:account_id, :inserted_at], name: :idx_transaction_account_id_inserted_at))
  end
end
