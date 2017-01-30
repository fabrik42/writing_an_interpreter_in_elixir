defmodule Monkey.Ast.ReturnStatement do
  alias Monkey.Ast.Node

  @enforce_keys [:token, :return_value]
  defstruct [:token, :return_value]

  defimpl Node, for: __MODULE__ do
    def token_literal(statement), do: statement.token.literal

    def node_type(_), do: :statement

    def to_string(%{return_value: nil} = statement) do
      Node.token_literal(statement)
    end
    def to_string(statement) do
      literal = Node.token_literal(statement)
      value = Node.to_string(statement.return_value)
      "#{literal} #{value}"
    end
  end
end

