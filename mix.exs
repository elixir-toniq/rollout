defmodule Rollout.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :rollout,
      version: @version,
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

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
      extra_applications: [:logger],
      mod: {Rollout.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:hlclock, "~> 1.0"},
      {:ex_doc, ">= 0.0.0", only: :dev}
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
