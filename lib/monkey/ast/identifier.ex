defmodule Monkey.Ast.Identifier do
  alias Monkey.Ast.Node

  @enforce_keys [:token, :value]
  defstruct [:token, :value]

  defimpl Node, for: __MODULE__ do
    def token_literal(identifier), do: identifier.token.literal

    def node_type(_), do: :expression

    def to_string(identifier), do: identifier.value
  end
end

