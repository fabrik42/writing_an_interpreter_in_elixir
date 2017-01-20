defmodule Monkey.Ast.ReturnStatement do
  alias Monkey.Ast.Node

  @enforce_keys [:token, :return_value]
  defstruct [:token, :return_value]

  defimpl Node, for: __MODULE__ do
    def token_literal(statement), do: statement.token.literal

    def node_type(_), do: :statement

    def to_string(statement) do
      out = [
        Node.token_literal(statement),
        " "
      ]

      out = if statement.value,
        do: out ++ [Node.to_string(statement.value)],
        else: out

      Enum.join(out)
    end
  end
end

