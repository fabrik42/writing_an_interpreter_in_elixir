defmodule Monkey.Ast.ArrayLiteral do
  alias Monkey.Ast.Node

  @enforce_keys [:token, :elements]
  defstruct [
    :token,
    # expression[]
    :elements
  ]

  defimpl Node, for: __MODULE__ do
    def token_literal(expression), do: expression.token.literal

    def node_type(_), do: :expression

    def to_string(expression) do
      elements =
        expression.elements
        |> Enum.map(&Node.to_string/1)
        |> Enum.join(", ")

      "[#{elements}]"
    end
  end
end
