defmodule Monkey.Object.Array do
  alias Monkey.Object.Object

  @enforce_keys [:elements]
  defstruct [:elements]

  defimpl Object, for: __MODULE__ do
    def type(_), do: "ARRAY"

    def inspect(obj) do
      elements = obj.elements
      |> Enum.map(&Object.inspect/1)
      |> Enum.join(", ")

      out = [
        "[",
        elements,
        "]"
      ]

      Enum.join(out)
    end
  end
end
