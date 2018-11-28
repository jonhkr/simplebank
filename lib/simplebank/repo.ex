defmodule SimpleBank.Repo do
  use Ecto.Repo,
    otp_app: :simplebank,
    adapter: Ecto.Adapters.MySQL
end