defmodule RolloutTest do
  use ExUnit.Case

  setup_all do
    Application.ensure_all_started(:rollout)
    nodes = LocalCluster.start_nodes("rollout-test", 2)

    {:ok, nodes: nodes}
  end

  setup do
    # Clean out storage in between test runs
    Groot.Storage.delete_all()

    :ok
  end

  test "flags are replicated across the cluster", %{nodes: nodes} do
    [n1, n2] = nodes

    Rollout.activate(:comments)

    eventually(fn ->
      assert Rollout.active?(:comments) == true
      assert :rpc.call(n1, Rollout, :active?, [:comments]) == true
      assert :rpc.call(n2, Rollout, :active?, [:comments]) == true
    end)

    Rollout.deactivate(:comments)

    eventually(fn ->
      assert Rollout.active?(:comments) == false
      assert :rpc.call(n1, Rollout, :active?, [:comments]) == false
      assert :rpc.call(n2, Rollout, :active?, [:comments]) == false
    end)
  end

  def eventually(f, retries \\ 0) do
    f.()
  rescue
    err ->
      if retries >= 10 do
        reraise err, __STACKTRACE__
      else
        :timer.sleep(500)
        eventually(f, retries + 1)
      end
  catch
    _exit, _term ->
      :timer.sleep(500)
      eventually(f, retries + 1)
  end
end
