defmodule Monkey.Ast.InfixExpression do
  alias Monkey.Ast.Node

  @enforce_keys [:token, :left, :operator, :right]
  defstruct [:token, # the operator token
             :left, # expression
             :operator,
             :right # expression
            ]

  defimpl Node, for: __MODULE__ do
    def token_literal(expression), do: expression.token.literal

    def node_type(_), do: :expression

    def to_string(expression) do
      out = [
        "(",
        Node.to_string(expression.left),
        " ",
        expression.operator,
        " ",
        Node.to_string(expression.right),
        ")"
      ]

      Enum.join(out)
    end
  end
end
