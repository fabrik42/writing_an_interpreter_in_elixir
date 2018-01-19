defmodule Monkey.Ast.CallExpression do
  alias Monkey.Ast.Node

  @enforce_keys [:token, :function, :arguments]
  defstruct [
    :token,
    # expression (identifier or function literal)
    :function,
    # expression[]
    :arguments
  ]

  defimpl Node, for: __MODULE__ do
    def token_literal(expression), do: expression.token.literal

    def node_type(_), do: :expression

    def to_string(expression) do
      function = Node.to_string(expression.function)

      arguments =
        expression.arguments
        |> Enum.map(&Node.to_string/1)
        |> Enum.join(", ")

      "#{function}(#{arguments})"
    end
  end
end
