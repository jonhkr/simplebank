defmodule SimpleBank.Repo.Migrations.CreateUniqueIndexOnAccountIban do
  use Ecto.Migration

  def change do
    create(unique_index(:account, [:iban], name: :idx_unique_accounbt_iban))
  end
end
