defmodule Monkey.Ast.IntegerLiteral do
  @enforce_keys [:token, :value]
  defstruct [:token, :value]

  defimpl Monkey.Ast.Node, for: __MODULE__ do
    def token_literal(literal), do: literal.token.literal

    def node_type(_), do: :expression

    def to_string(literal), do: literal.token.literal
  end
end
