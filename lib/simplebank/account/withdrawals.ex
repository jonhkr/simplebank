defmodule SimpleBank.Withdrawals do
  
  alias SimpleBank.{Repo, Accounts, Withdrawal}

  def create_withdrawal(account_id, amount) do
    Repo.transaction fn ->
      result = Accounts.debit_account(account_id, Decimal.new(amount), "withdrawal")
      |> register_withdrawal

      case result do
        {:ok, wd} -> wd
        {:error, error} -> Repo.rollback(error)
      end
    end
  end

  defp register_withdrawal({:error, _} = error), do: error
  defp register_withdrawal({:ok, transaction}) do
    changeset = Withdrawal.changeset(%Withdrawal{}, %{
      account_id: transaction.account_id,
      transaction_id: transaction.id,
      amount: Decimal.abs(transaction.amount)
    })

    Repo.insert(changeset)
  end
end