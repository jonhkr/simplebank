use Mix.Config

config :simplebank, SimpleBank.Repo,
  database: "simplebank_test",
  username: "root",
  password: "",
  hostname: "localhost",
  port: "3306",
  pool: Ecto.Adapters.SQL.Sandbox

config :bcrypt_elixir, log_rounds: 4

config :joken, default_signer: "travis"

config :simplebank, port: 3333