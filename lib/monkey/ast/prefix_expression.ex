defmodule Monkey.Ast.PrefixExpression do
  alias Monkey.Ast.Node

  @enforce_keys [:token, :operator, :right]
  defstruct [:token, # the prefix token
             :operator,
             :right  # expression
            ]

  defimpl Node, for: __MODULE__ do
    def token_literal(expression), do: expression.token.literal

    def node_type(_), do: :expression

    def to_string(expression) do
      out = [
        "(",
        expression.operator,
        Node.to_string(expression.right),
        ")"
      ]

      Enum.join(out)
    end
  end
end
