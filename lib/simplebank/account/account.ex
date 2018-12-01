defmodule SimpleBank.Account do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :user_id, :iban, :balance, :currency, :inserted_at]}
  schema "account" do
    field :user_id, :integer
    field :iban
    field :currency
    field :balance, :decimal, virtual: true, default: 0

    has_many :transactions, SimpleBank.Transaction

    timestamps()
  end

  @required_fields [:user_id, :iban, :currency]

  def changeset(user, params \\ :empty) do
    user
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end
end