defmodule Monkey.Object.Function do
  alias Monkey.Object.Object
  alias Monkey.Ast.Node

  @enforce_keys [:parameters, :body, :environment]
  defstruct [
    # identifiers[]
    :parameters,
    # block statement
    :body,
    :environment
  ]

  defimpl Object, for: __MODULE__ do
    def type(_), do: "FUNCTION"

    def inspect(obj) do
      params =
        obj.parameters
        |> Enum.map(&Node.to_string/1)
        |> Enum.join(", ")

      body = Node.to_string(obj.body)
      "fn(#{params}) {#{body}}"
    end
  end
end
