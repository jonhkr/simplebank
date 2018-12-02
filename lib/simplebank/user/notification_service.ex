defmodule SimpleBank.NotificationService do
  @moduledoc """
  Service implementation to handle user notification
  
  This is a very simple implementation that doesn't really
  send anything to the users.
  
  """

  require Logger

  alias SimpleBank.{Accounts, Users}

  def process(:withdrawal_created, data) do
    account = Accounts.get_account(data.account_id)
    user = Users.get_user(account.user_id)

    # TODO: notify the user
    Logger.info("Notifying user with id #{user.id} about withdrawal {amount: #{data.amount}}")

    :ok
  end
end