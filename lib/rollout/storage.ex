defmodule Rollout.Storage do
  @moduledoc false

  use GenServer

  alias Rollout.Flags

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def percentage(flag) do
    case :ets.lookup(__MODULE__, flag) do
      [] ->
        0

      [{^flag, percent}] ->
        percent
    end
  end

  def set_percentage(flag, percentage) do
    GenServer.call(__MODULE__, {:set_percentage, flag, percentage})
  end

  def init(_args) do
    :net_kernel.monitor_nodes(true)
    tab = __MODULE__ = :ets.new(__MODULE__, [:named_table, :set, :protected])
    flags = Flags.new()
    schedule_sync_timeout()

    {:ok, %{table: tab, flags: flags}}
  end

  def handle_call({:set_percentage, flag, percent}, _from, data) do
    flags = Flags.update(data.flags, flag, percent)
    :ets.insert(__MODULE__, {flag, Flags.value(flags, flag)})
    GenServer.abcast(__MODULE__, {:update_flag, Flags.flag(flags, flag)})

    {:reply, :ok, %{data | flags: flags}}
  end

  def handle_cast({:update_flag, register}, data) do
    flags = Flags.update(data.flags, register)
    :ets.insert(data.table, {register.key, Flags.value(flags, register.key)})

    {:noreply, %{data | flags: flags}}
  end

  def handle_cast({:update_flags, flags}, data) do
    new_flags = Flags.merge(data.flags, flags)

    for {key, flag} <- new_flags do
      :ets.insert(data.table, {key, flag.value})
    end

    {:noreply, %{data | flags: new_flags}}
  end

  def handle_info(msg, data) do
    case msg do
      {:nodeup, node} ->
        GenServer.cast({__MODULE__, node}, {:update_flags, data.flags})
        {:noreply, data}

      :sync_timeout ->
        GenServer.abcast(__MODULE__, {:update_flags, data.flags})
        schedule_sync_timeout()
        {:noreply, data}

      _msg ->
        {:noreply, data}
    end
  end

  defp schedule_sync_timeout do
    # Wait between 10 and 20 seconds before doing another sync
    next_timeout = (:rand.uniform(10) * 1000) + 10_000
    Process.send_after(self(), :sync_timeout, next_timeout)
  end
end
