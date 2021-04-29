defmodule Rollout.MixProject do
  use Mix.Project

  @version "0.2.0"

  def project do
    [
      app: :rollout,
      version: @version,
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),

      description: description(),
      package: package(),
      name: "Rollout",
      source_url: "https://github.com/keathley/rollout",
      docs: docs(),
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:groot, "~> 0.1"},
      {:norm, "~> 0.10"},

      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
      {:local_cluster, "~> 1.0", only: [:dev, :test]},
      {:schism, "~> 1.0", only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  def aliases do
    [
      test: ["test --no-start"]
    ]
  end

  def description do
    """
    Rollout allows you to flip features quickly and easily. It relies on
    distributed erlang and uses LWW-Registers and Hybrid-logical clocks
    to provide maximum availability and low latency.
    """
  end

  def package do
    [
      name: "rollout",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/keathley/rollout"},
    ]
  end

  def docs do
    [
      source_ref: "v#{@version}",
      source_url: "https://github.com/keathley/rollout",
      main: "Rollout",
    ]
  end
end
