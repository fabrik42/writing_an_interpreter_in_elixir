defmodule Monkey.Object.Function do
  alias Monkey.Object.Object
  alias Monkey.Ast.Node

  @enforce_keys [:parameters, :body, :environment]
  defstruct [:parameters, # identifiers[]
             :body, # block statement
             :environment]

  defimpl Object, for: __MODULE__ do
    def type(_), do: "FUNCTION"

    def inspect(obj) do
      params = obj.parameters
      |> Enum.map(&Node.to_string/1)
      |> Enum.join(", ")

      out = [
        "fn",
        "(",
        params,
        ")",
        Node.to_string(obj.body)
      ]

      Enum.join(out)
    end
  end
end
