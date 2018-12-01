defmodule SimpleBank.Accounts do
  import Ecto.Query, only: [from: 2]

  alias SimpleBank.{Repo, Account, Transaction}

  @account_query from a in Account,
      select: %{a | balance: coalesce(
        fragment("select sum(t.amount)
          from transaction t
          where t.account_id = ?", a.id), 0)}

  def create_account(user, initial_deposit, currency) do
    changeset = Account.changeset(%Account{}, %{
      user_id: user.id,
      iban: gen_iban(),
      currency: currency
    })

    create_account(changeset, initial_deposit)
  end

  def get_user_accounts(user_id) do
    query = from a in @account_query,
      where: a.user_id == ^user_id

    Repo.all(query)
  end

  def get_account(account_id) do
    query = from a in @account_query,
      where: a.id == ^account_id

    Repo.one(query)
  end

  defp gen_iban(), do: Ecto.UUID.generate()

  defp create_account(%Ecto.Changeset{valid?: false} = changeset, _initial_deposit), do: {:error, changeset}
  defp create_account(%Ecto.Changeset{valid?: true} = changeset, initial_deposit) do
    Repo.transaction fn ->
      result = Repo.insert(changeset)
      |> create_initial_deposit(initial_deposit)

      case result do
        {:ok, transaction} -> get_account(transaction.account_id)
        {:error, error} -> Repo.rollback(error)
      end
    end
  end


  defp create_initial_deposit({:error, _} = error, _initial_deposit), do: error
  defp create_initial_deposit({:ok, account}, initial_deposit) do
    changeset = Transaction.changeset(%Transaction{}, %{
      account_id: account.id,
      amount: initial_deposit,
      type: "initial_deposit"
    })

    Repo.insert(changeset)
  end
end