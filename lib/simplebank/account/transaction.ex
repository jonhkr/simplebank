defmodule SimpleBank.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :account_id, :amount, :type, :inserted_at]}
  schema "transaction" do
    field :account_id, :integer
    field :amount, :decimal
    field :type

    timestamps(updated_at: false)
  end

  @required_fields [:account_id, :amount, :type]

  def changeset(user, params \\ :empty) do
    user
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end
end