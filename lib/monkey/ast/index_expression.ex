defmodule Monkey.Ast.IndexExpression do
  alias Monkey.Ast.Node

  @enforce_keys [:token, :left, :index]
  defstruct [
    :token,
    # expression
    :left,
    # expression
    :index
  ]

  defimpl Node, for: __MODULE__ do
    def token_literal(expression), do: expression.token.literal

    def node_type(_), do: :expression

    def to_string(expression) do
      left = Node.to_string(expression.left)
      index = Node.to_string(expression.index)
      "(#{left}[#{index}])"
    end
  end
end
