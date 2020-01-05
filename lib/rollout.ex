defmodule Rollout do
  @moduledoc """
  Rollout allows you to flip features quickly and easily. It relies on
  distributed erlang and uses LWW-register and Hybrid-logical clocks
  to provide maximum availability. Rollout has no dependency on an external
  service such as redis which means rollout feature flags can be used in the
  critical path of a request with minimal latency increase.

  ## Usage

  Rollout provides a simple api for enabling and disabling feature flags across
  your cluster. A feature flag can be any term.

  ```elixir
  # Check if a feature is active
  Rollout.active?(:blog_post_comments)
  # => false

  # Activate the feature
  Rollout.activate(:blog_post_comments)

  # De-activate the feature
  Rollout.deactivate(:blog_post_comments)
  ```

  You can also activate a feature a certain percentage of the time.

  ```elixir
  Rollout.activate_percentage(:blog_post_comments, 20)
  ```

  You can run this function on one node in your cluster and the updates will
  be propogated across the system. This means that updates to feature flags may
  not be instantaneous across the cluster but under normal conditions should propogate
  quickly. This is a tradeoff I've made in order to maintain the low latency when
  checking if a flag is enabled.

  ## How does Rollout work?

  Rollout utilizes [Groot](https://github.com/keathley/groot) for replicating flags
  across your cluster. Please look at the groot docs for implementation details.
  """
  use Norm

  @doc """
  Checks to see if a feature is active or not.
  """
  def active?(flag) do
    case Groot.get(flag) do
      nil ->
        false

      0 ->
        false

      100 ->
        true

      val ->
        :rand.uniform(100) <= val
    end
  end

  @doc """
  Fully activates a feature flag.
  """
  def activate(flag) do
    activate_percentage(flag, 100)
  end

  @doc """
  Disables a feature flag.
  """
  def deactivate(flag) do
    activate_percentage(flag, 0)
  end

  @doc """
  Activates a feature flag for a percentage of requests. An integer between 0 and 100
  must be provided. Deciding whether a flag is active is done with the following
  calculation: `:rand.uniform(100) <= provided_percentage`
  """
  def activate_percentage(flag, percentage) when is_integer(percentage) and 0 <= percentage and percentage <= 100 do
    Groot.set(flag, percentage)
  end
end

