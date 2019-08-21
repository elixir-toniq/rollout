defmodule RolloutTest do
  use ExUnit.Case
  doctest Rollout

  test "greets the world" do
    assert Rollout.hello() == :world
  end
end
