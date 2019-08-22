defmodule Rollout do
  @moduledoc """
  Documentation for Rollout.
  """

  alias Rollout.Storage

  @doc """
  Checks to see if a feature is active or not.
  """
  def active?(flag) do
    case Storage.percentage(flag) do
      100 ->
        true

      0 ->
        false

      val ->
        :rand.uniform(100) <= val
    end
  end

  @doc """
  Fully activates a feature flag.
  """
  def activate(flag) do
    Storage.set_percentage(flag, 100)
  end

  @doc """
  Activates a feature flag for a percentage of requests. An integer between 0 and 100
  must be provided. Deciding whether a flag is active is done with the following
  calculation: `:rand.uniform(100) <= provided_percentage`
  """
  def activate_percentage(flag, percentage) when is_integer(percentage) and 0 <= percentage and percentage <= 100 do
    Storage.set_percentage(flag, percentage)
  end

  @doc """
  Disables a feature flag.
  """
  def deactivate(flag) do
    Storage.set_percentage(flag, 0)
  end
end

