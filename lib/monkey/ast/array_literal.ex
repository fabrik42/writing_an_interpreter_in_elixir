defmodule Monkey.Ast.ArrayLiteral do
  alias Monkey.Ast.Node

  @enforce_keys [:token, :elements]
  defstruct [:token,
             :elements # expression[]
            ]

  defimpl Node, for: __MODULE__ do
    def token_literal(expression), do: expression.token.literal

    def node_type(_), do: :expression

    def to_string(expression) do
      elements = expression.elements
      |> Enum.map(&Node.to_string/1)
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
