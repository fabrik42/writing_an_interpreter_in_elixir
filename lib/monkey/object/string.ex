defmodule Monkey.Object.String do
  alias Monkey.Object.Object

  @enforce_keys [:value]
  defstruct [:value]

  defimpl Object, for: __MODULE__ do
    def type(_), do: "STRING"

    def inspect(obj), do: obj.value
  end
end
