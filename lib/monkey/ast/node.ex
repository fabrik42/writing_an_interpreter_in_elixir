defprotocol Monkey.Ast.Node do
  @doc "Returns the literal value of the token"
  def token_literal(node)

  @doc "The type of the node, either :statement or :expression"
  def node_type(node)

  @doc "Prints the node as a string"
  def to_string(node)
end
