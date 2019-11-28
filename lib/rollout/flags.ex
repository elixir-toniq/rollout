defmodule Rollout.Flags do
  @moduledoc false

  defmodule Register do
    @moduledoc false
    # LWW Register.

    # Creates a new register
    def new(key, val) do
      {:ok, hlc} = HLClock.send_timestamp(Rollout.Clock)

      %{key: key, value: val, hlc: hlc}
    end

    # Updates the value and creates a new HLC for our register
    def update(register, val) do
      {:ok, hlc} = HLClock.send_timestamp(Rollout.Clock)

      %{register | value: val, hlc: hlc}
    end

    # Finds the "latest" register by comparing HLCs
    def latest(reg1, reg2) do
      [reg1, reg2]
      |> Enum.reject(&is_nil/1)
      |> Enum.sort_by(& &1, fn a, b -> !HLClock.before?(a.hlc, b.hlc) end)
      |> Enum.at(0)
    end
  end

  # Creates a new group of flags
  def new() do
    %{}
  end

  # Updates a specific flag in the group
  def update(flags, register) when is_map(register) do
    Map.update(flags, register.key, register, fn existing_register ->
      Register.latest(register, existing_register)
    end)
  end

  # Update a specific flag in the group setting its percentage to a specific
  # percent
  def update(flags, flag, percentage) do
    Map.update(flags, flag, Register.new(flag, percentage), fn reg ->
      Register.update(reg, percentage)
    end)
  end

  # Merge a group of flags. We always take the latest register based on HLCs
  def merge(f1, f2) do
    keys =
      [Map.keys(f1), Map.keys(f2)]
      |> List.flatten()
      |> Enum.uniq

    keys
    |> Enum.map(fn key -> {key, Register.latest(f1[key], f2[key])} end)
    |> Enum.into(%{})
  end

  # Get a specific flag
  def flag(flags, flag) do
    Map.fetch!(flags, flag)
  end

  # Get the current value of a specific flag.
  def value(flags, flag) do
    case flags[flag] do
      nil ->
        0

      %{value: val} ->
        val
    end
  end
end
