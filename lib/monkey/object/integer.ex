defmodule Monkey.Object.Integer do
  alias Monkey.Object.Object
  alias Monkey.Object.Hash

  @enforce_keys [:value]
  defstruct [:value]

  defimpl Object, for: __MODULE__ do
    def type(_), do: "INTEGER"

    def inspect(obj), do: Integer.to_string(obj.value)
  end

  defimpl Hash.Hashable, for: __MODULE__ do
    def hash(obj) do
      %Hash.Key{type: Object.type(obj), value: obj.value}
    end
  end
end
