defmodule Monkey.Object.Boolean do
  alias Monkey.Object.{Object, Hash}

  @enforce_keys [:value]
  defstruct [:value]

  defimpl Object, for: __MODULE__ do
    def type(_), do: "BOOLEAN"

    def inspect(obj), do: Atom.to_string(obj.value)
  end

  defimpl Hash.Hashable, for: __MODULE__ do
    def hash(obj) do
      value = case obj.value do
                :true -> 1
                :false -> 0
              end

      %Hash.Key{type: Object.type(obj), value: value}
    end
  end
end
