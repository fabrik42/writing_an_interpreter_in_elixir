defprotocol Monkey.Object.Object do
  @doc "Returns the type of the object as a string"
  def type(obj)

  @doc "Returns the value of the object as a string"
  def inspect(obj)
end
