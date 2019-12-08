defmodule WaoBirthday.MixProject do
  use Mix.Project

  def project do
    [
      app: :wao_birthday,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :mnesia],
      mod: {WaoBirthday, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:alchemy, "~> 0.6.4", hex: :discord_alchemy},
      {:memento, "~> 0.3.1"},
      {:timex, "~> 3.6"},
      {:honeydew, "~> 1.4"},
      {:quantum, "~> 2.3"},
      {:poison, "~> 4.0"},
    ]
  end
end
