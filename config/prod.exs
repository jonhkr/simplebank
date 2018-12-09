use Mix.Config

config :bcrypt_elixir, log_rounds: 12

config :logger,
  level: :info,
  backends: [{SimpleBank.Logger.LogstashBackend, :logstash}, :console]