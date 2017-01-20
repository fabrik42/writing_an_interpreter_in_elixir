defmodule Monkey.Ast.ExpressionStatement do
  alias Monkey.Ast.Node

  @enforce_keys [:token, :expression]
  defstruct [:token, :expression]

  defimpl Node, for: __MODULE__ do
    def token_literal(statement), do: statement.token.literal

    def node_type(_), do: :statement

    def to_string(statement) do
      if statement.expression do
        Node.to_string(statement.expression)
      else
        ""
      end
    end
  end
end

