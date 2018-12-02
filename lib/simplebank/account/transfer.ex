defmodule SimpleBank.Transfer do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [
    :id, :account_id, :transaction_id,
    :amount, :direction, :source,
    :destination, :inserted_at]}
  schema "transfer" do
    field :account_id, :integer
    field :transaction_id, :integer
    field :amount, :decimal
    field :direction
    field :source
    field :destination

    timestamps(updated_at: false)
  end

  @required_fields [:account_id, :transaction_id, :amount, :direction]
  @optinal_fields [:source, :destination]

  def changeset(user, params \\ :empty) do
    user
    |> cast(params, @required_fields ++ @optinal_fields)
    |> validate_required(@required_fields)
    |> validate_number(:amount, greater_than: 0)
    |> validate_inclusion(:direction, ["in", "out"])
    |> validate_direction()
  end

  defp validate_direction(%Ecto.Changeset{valid?: false} = changeset), do: changeset
  defp validate_direction(%Ecto.Changeset{valid?: true, changes: %{direction: direction}} = changeset) do
    case direction do
      "in" -> validate_required(changeset, [:source])
      "out" -> validate_required(changeset, [:destination])
    end
  end
end