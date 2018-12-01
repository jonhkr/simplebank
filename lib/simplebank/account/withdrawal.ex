defmodule SimpleBank.Withdrawal do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :account_id, :transaction_id, :amount, :inserted_at]}
  schema "withdrawal" do
    field :account_id, :integer
    field :transaction_id, :integer
    field :amount, :decimal

    timestamps(updated_at: false)
  end

  @required_fields [:account_id, :transaction_id, :amount]

  def changeset(user, params \\ :empty) do
    user
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end
end
