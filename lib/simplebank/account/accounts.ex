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

  def get_account_by_iban(iban) do
    query = from a in @account_query,
      where: a.iban == ^iban

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

  def credit_account(account_id, amount, type) do
    Repo.transaction fn ->
      query = from a in @account_query,
        where: a.id == ^account_id

      account = Repo.one(query)

      if is_nil(account) do
        {:error, %Error{message: "account not found"}}
      else
        case create_transaction(account, positive_amount(amount), type) do
          {:ok, transaction} -> transaction
          {:error, error} -> Repo.rollback(error) 
        end
      end
    end
  end

  def generate_report("summary", account_id, start_date, end_date) do
    with {:ok, start_date_time, end_date_time} <- parse_report_dates(start_date, end_date) do
      query = from t in Transaction,
        where: t.account_id == ^account_id and
          t.inserted_at >= ^start_date_time and
          t.inserted_at <= ^end_date_time,
        select: t

      Repo.transaction fn ->
        # We could aggregate this in using a database query
        # but it is preferable to give this task to the application
        # to reduce the database load.
        # The stream could be parallelized to make the computation faster
        Repo.stream(query)
        |> Enum.reduce(%{
          transaction_count: 0,
          credit_count: 0,
          debit_count: 0,
          credit_amount: Decimal.new(0),
          debit_amount: Decimal.new(0),
          start_date: NaiveDateTime.to_date(start_date_time),
          end_date: NaiveDateTime.to_date(end_date_time)
        }, fn t, acc ->
          case t.amount.sign do
            +1 ->
              acc
              |> Map.update!(:credit_count, &(&1 + 1))
              |> Map.update!(:credit_amount, &(Decimal.add(&1, t.amount)))
            -1 ->
              acc
              |> Map.update!(:debit_count, &(&1 + 1))
              |> Map.update!(:debit_amount, &(Decimal.add(&1, Decimal.abs(t.amount))))
          end
          |> Map.update!(:transaction_count, &(&1 + 1))
        end)
      end
    end
  end
  def generate_report(type, _account_id, _start_date, _end_date) do
    {:error, %Error{message: "unknown report type #{type}"}}
  end

  defp parse_report_dates(nil, _), do: {:error, %Error{message: "start date is required"}}
  defp parse_report_dates(_, nil), do: {:error, %Error{message: "end date is required"}}
  defp parse_report_dates(start_date_s, end_date_s) do
     with(
      {:ok, start_date} <- Date.from_iso8601(start_date_s),
      {:ok, start_date_time} = NaiveDateTime.new(start_date, ~T[00:00:00.000]),
      {:ok, end_date} <- Date.from_iso8601(end_date_s),
      {:ok, end_date_time} = NaiveDateTime.new(end_date, ~T[23:59:59.999])
      ) do

      if NaiveDateTime.diff(start_date_time, end_date_time) <= 0 do
        {:ok, start_date_time, end_date_time}
      else
        {:error, %Error{message: "start date should be before end date"}}
      end
    else
      {:error, :invalid_format} -> {:error, %Error{message: "invalid date format"}}
      {:error, :invalid_date} -> {:error, %Error{message: "invalid date"}}
      error -> error
    end
  end

  defp negative_amount(amount) do
    amount
    |> Decimal.abs
    |> Decimal.minus
  end

  defp positive_amount(amount) do
    amount
    |> Decimal.abs
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