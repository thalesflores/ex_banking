defmodule ExBanking.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_banking,
      version: "0.1.0",
      elixir: "~> 1.9.1",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ExBanking.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end
end
