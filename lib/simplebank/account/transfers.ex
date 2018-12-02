defmodule SimpleBank.Transfers do

  alias SimpleBank.{Repo, Accounts, Transfer, Error}

  def send_money(account_id, amount, destination_iban) do
    changeset = Transfer.changeset(%Transfer{}, %{
      account_id: account_id,
      transaction_id: -1,
      amount: amount,
      direction: "out",
      destination: destination_iban
    })

    case Accounts.get_account(account_id) do
      nil -> {:error, %Error{message: "account not found"}}
      source_account -> execute_out_transfer(changeset, source_account.iban)
    end
  end

  defp execute_out_transfer(%Ecto.Changeset{valid?: false} = changeset, _source_iban), do: {:error, changeset}
  defp execute_out_transfer(%Ecto.Changeset{valid?: true, changes: changes} = changeset, source_iban) do
    case Accounts.get_account_by_iban(changes.destination) do
      nil -> {:error, %Error{message: "destination account not found"}}
      destination_account ->
        Repo.transaction fn ->
          case create_transfer(changeset) do
            {:ok, transfer} ->
              receive_money(destination_account.id, changes.amount, source_iban)
              transfer
            {:error, error} -> Repo.rollback(error)
          end
        end
    end
  end

  defp receive_money(account_id, amount, source_iban) do
    changeset = Transfer.changeset(%Transfer{}, %{
      account_id: account_id,
      transaction_id: -1,
      amount: amount,
      direction: "in",
      source: source_iban
    })

    create_transfer(changeset)
  end

  defp create_transfer(%Ecto.Changeset{valid?: true, changes: changes} = changeset) do
    Repo.transaction fn ->
      result = create_transaction(changes.direction, changes.account_id, changes.amount)
      |> register_transfer(changeset)

      case result do
        {:ok, transfer} -> transfer
        {:error, error} -> Repo.rollback(error)
      end
    end
  end

  defp create_transaction("out", account_id, amount) do
    Accounts.debit_account(account_id, amount, "transfer")
  end

  defp create_transaction("in", account_id, amount) do
    Accounts.credit_account(account_id, amount, "transfer")
  end
  
  defp register_transfer({:error, _} = error, _), do: error
  defp register_transfer({:ok, transaction}, changeset) do
    changeset
    |> Transfer.changeset(%{transaction_id: transaction.id})
    |> Repo.insert()
  end
end