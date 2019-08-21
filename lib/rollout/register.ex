defmodule Rollout.Register do
  def new(key, val) do
    hlc = HLClock.send_timestamp(Rollout.Clock)
    %{key: key, value: val, hlc: hlc}
  end

  def latest(reg1, reg2) do
    latest =
      [reg1, reg2]
      |> Enum.sort_by(& &1, fn a, b -> !HLClock.before?(a.hlc, b.hlc) end)
      |> Enum.at(0)
  end

  def value(%{value: v}), do: v
end
