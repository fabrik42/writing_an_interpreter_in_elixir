defmodule Monkey.Ast.IfExpression do
  alias Monkey.Ast.Node

  @enforce_keys [:token, :condition, :consequence]
  defstruct [
    :token,
    # expression
    :condition,
    # block statement
    :consequence,
    # block statement
    :alternative
  ]

  defimpl Node, for: __MODULE__ do
    def token_literal(expression), do: expression.token.literal

    def node_type(_), do: :expression

    def to_string(expression) do
      condition = Node.to_string(expression.condition)
      consequence = Node.to_string(expression.consequence)
      alternative = alternative_to_string(expression.alternative)
      "if#{condition} #{consequence}#{alternative}"
    end

    defp alternative_to_string(nil), do: ""

    defp alternative_to_string(alternative) do
      string = Node.to_string(alternative)
      "else #{string}"
    end
  end
end
