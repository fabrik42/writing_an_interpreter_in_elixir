defmodule Monkey.Object.Environment do
  @enforce_keys [:store]
  defstruct [:store, :outer]

  def build do
    %Monkey.Object.Environment{store: %{}}
  end

  def build_enclosed(outer) do
    env = build()
    %{env | outer: outer}
  end

  def get(env, name) do
    value = Map.get(env.store, name)
    cond do
      is_nil(value) && env.outer -> __MODULE__.get(env.outer, name)
      true -> value
    end
  end

  def set(env, name, val), do: %{env | store: Map.put(env.store, name, val)}
end
