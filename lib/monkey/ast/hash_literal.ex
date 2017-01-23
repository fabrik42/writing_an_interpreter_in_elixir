defmodule Monkey.Ast.HashLiteral do
  alias Monkey.Ast.Node

  @enforce_keys [:token, :pairs]
  defstruct [:token,
             :pairs # %{expression => expression}
            ]

  defimpl Node, for: __MODULE__ do
    def token_literal(expression), do: expression.token.literal

    def node_type(_), do: :expression

    def to_string(expression) do
      pairs = expression.pairs
      |> Enum.map(fn({key, value}) ->
        "#{Node.to_string(key)}:#{Node.to_string(value)}"
      end)
      |> Enum.join(", ")

      out = [
        "{",
        pairs,
        "}"
      ]

      Enum.join(out)
    end
  end
end
