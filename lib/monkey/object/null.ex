defmodule Monkey.Object.Null do
  alias Monkey.Object.Object

  defstruct []

  defimpl Object, for: __MODULE__ do
    def type(_), do: "NULL"

    def inspect(_), do: "null"
  end
end
