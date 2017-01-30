defmodule Monkey.Ast.ExpressionStatement do
  alias Monkey.Ast.Node

  @enforce_keys [:token, :expression]
  defstruct [:token, :expression]

  defimpl Node, for: __MODULE__ do
    def token_literal(statement), do: statement.token.literal

    def node_type(_), do: :statement

    def to_string(%{expression: nil}), do: ""
    def to_string(statement), do: Node.to_string(statement.expression)
  end
end

