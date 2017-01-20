defmodule Monkey.Object.Boolean do
  alias Monkey.Object.Object

  @enforce_keys [:value]
  defstruct [:value]

  defimpl Object, for: __MODULE__ do
    def type(_), do: "BOOLEAN"

    def inspect(obj), do: Atom.to_string(obj.value)
  end
end
