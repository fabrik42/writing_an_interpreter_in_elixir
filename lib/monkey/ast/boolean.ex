defmodule Monkey.Ast.BooleanLiteral do
  alias Monkey.Ast.Node

  @enforce_keys [:token, :value]
  defstruct [:token, :value]

  defimpl Node, for: __MODULE__ do
    def token_literal(expression), do: expression.token.literal

    def node_type(_), do: :expression

    def to_string(expression), do: expression.token.literal
  end
end
