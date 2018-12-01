defmodule SimpleBank.Accounts do
  import Ecto.Query, only: [from: 2]

  alias SimpleBank.{Repo, Account, Transaction, Error}

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

  def get_user_account(user_id, currency) do
    query = from a in @account_query,
      where: a.user_id == ^user_id and
        a.currency == ^currency

    Repo.one(query)
  end

  def get_account(account_id) do
    query = from a in @account_query,
      where: a.id == ^account_id

    Repo.one(query)
  end

  def debit_account(account_id, amount, type) do
    Repo.transaction fn ->
      query = from a in @account_query,
        where: a.id == ^account_id,
        lock: "FOR UPDATE"

      account = Repo.one(query)

      if is_nil(account) do
        {:error, %Error{message: "account not found"}}
      else
        case create_transaction(account, negative_amount(amount), type) do
          {:ok, transaction} -> transaction
          {:error, error} -> Repo.rollback(error) 
        end
      end
    end
  end

  defp negative_amount(amount) do
    amount
    |> Decimal.abs
    |> Decimal.minus
  end

  defp create_transaction(account, amount, type) do
    if Decimal.cmp(Decimal.add(account.balance, amount), 0) == :lt do
      {:error, %Error{message: "insufficient funds"}}
    else
      changeset = Transaction.changeset(%Transaction{}, %{
        account_id: account.id,
        amount: amount,
        type: type
      })

      Repo.insert(changeset)
    end
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
    create_transaction(account, initial_deposit, "initial_deposit")
  end
end