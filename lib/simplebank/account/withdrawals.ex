defmodule SimpleBank.Withdrawals do
  
  alias SimpleBank.{Repo, Accounts, Withdrawal, NotificationService}

  def create_withdrawal(account_id, amount) do
    changeset = Withdrawal.changeset(%Withdrawal{}, %{
      account_id: account_id,
      transaction_id: -1,
      amount: amount
    })

    case create_withdrawal(changeset) do
      {:ok, withdrawal} = result ->
        # publish the event only after transaction commit
        withdrawal_created(withdrawal)
        result
      result -> result
    end
  end

  defp create_withdrawal(%Ecto.Changeset{valid?: false} = changeset), do: {:error, changeset}
  defp create_withdrawal(%Ecto.Changeset{valid?: true, changes: changes} = changeset) do
    Repo.transaction fn ->
      result = Accounts.debit_account(changes.account_id, changes.amount, "withdrawal")
      |> register_withdrawal(changeset)

      case result do
        {:ok, wd} -> wd
        {:error, error} ->
          Repo.rollback(error)
      end
    end
  end
  
  defp register_withdrawal({:error, _} = error, _), do: error
  defp register_withdrawal({:ok, transaction}, changeset) do
    changeset
    |> Withdrawal.changeset(%{transaction_id: transaction.id})
    |> Repo.insert()
  end

  defp withdrawal_created(wd) do
    NotificationService.process(:withdrawal_created, wd)
  end
end