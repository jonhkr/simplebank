defmodule SimpleBank.MixProject do
  use Mix.Project

  def project do
    [
      app: :simplebank,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :plug_cowboy],
      mod: {SimpleBank.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.1"},
      {:ecto_sql, "~> 3.0"},
      {:mariaex, ">= 0.0.0"},
      {:comeonin, "~> 4.1"},
      {:bcrypt_elixir, "~> 1.1"},
    ]
  end
end
