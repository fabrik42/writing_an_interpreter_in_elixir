defmodule Monkey.Object.Integer do
  alias Monkey.Object.Object

  @enforce_keys [:value]
  defstruct [:value]

  defimpl Object, for: __MODULE__ do
    def type(_), do: "INTEGER"

    def inspect(obj), do: Integer.to_string(obj.value)
  end
end
