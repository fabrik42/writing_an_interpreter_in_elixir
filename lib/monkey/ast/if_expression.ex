defmodule Monkey.Ast.IfExpression do
  alias Monkey.Ast.Node

  @enforce_keys [:token, :condition, :consequence]
  defstruct [:token,
             :condition, # expression
             :consequence, # block statement
             :alternative # block statement
            ]

  defimpl Node, for: __MODULE__ do
    def token_literal(expression), do: expression.token.literal

    def node_type(_), do: :expression

    def to_string(expression) do
      out = [
        "if",
        Node.to_string(expression.condition),
        " ",
        Node.to_string(expression.consequence)
      ]

      out = if expression.alternative do
        out ++ [
          "else ",
          Node.to_string(expression.alternative)
        ]
      else
        out
      end

      Enum.join(out)
    end
  end
end
