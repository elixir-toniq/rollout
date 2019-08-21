defmodule Rollout.Flags do
  @moduledoc false

  defmodule Register do
    @moduledoc false

    def new(key, val) do
      {:ok, hlc} = HLClock.send_timestamp(Rollout.Clock)

      %{key: key, value: val, hlc: hlc}
    end

    def update(register, val) do
      {:ok, hlc} = HLClock.send_timestamp(Rollout.Clock)

      %{register | value: val, hlc: hlc}
    end

    def latest(reg1, reg2) do
      [reg1, reg2]
      |> Enum.reject(&is_nil/1)
      |> Enum.sort_by(& &1, fn a, b -> !HLClock.before?(a.hlc, b.hlc) end)
      |> Enum.at(0)
    end
  end

  def new() do
    %{}
  end

  def update(flags, register) when is_map(register) do
    Map.update(flags, register.key, register, fn existing_register ->
      Register.latest(register, existing_register)
    end)
  end

  def update(flags, flag, percentage) do
    Map.update(flags, flag, Register.new(flag, percentage), fn reg ->
      Register.update(reg, percentage)
    end)
  end

  def merge(f1, f2) do
    keys =
      [Map.keys(f1), Map.keys(f2)]
      |> List.flatten()
      |> Enum.uniq

    keys
    |> Enum.map(fn key -> {key, Register.latest(f1[key], f2[key])} end)
    |> Enum.into(%{})
  end

  def flag(flags, flag) do
    Map.fetch!(flags, flag)
  end

  def value(flags, flag) do
    case flags[flag] do
      nil ->
        0

      %{value: val} ->
        val
    end
  end
end
