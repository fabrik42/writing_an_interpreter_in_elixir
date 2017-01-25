defmodule Monkey.Object.Builtin do
  alias Monkey.Object.Object

  @enforce_keys [:fn]
  defstruct [:fn]

  defimpl Object, for: __MODULE__ do
    def type(_), do: "BUILTIN"

    def inspect(_), do: "builtin function"
  end
end
