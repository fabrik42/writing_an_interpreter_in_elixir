defmodule Monkey.Ast.FunctionLiteral do
  alias Monkey.Ast.Node

  @enforce_keys [:token, :parameters, :body]
  defstruct [:token,
             :parameters, # identifier[]
             :body # block statement
            ]

  defimpl Node, for: __MODULE__ do
    def token_literal(expression), do: expression.token.literal

    def node_type(_), do: :expression

    def to_string(expression) do
      literal = Node.token_literal(expression)
      body = Node.to_string(expression.body)
      params = expression.parameters
      |> Enum.map(&Node.to_string/1)
      |> Enum.join(", ")

      "#{literal}(#{params})#{body}"
    end
  end
end
