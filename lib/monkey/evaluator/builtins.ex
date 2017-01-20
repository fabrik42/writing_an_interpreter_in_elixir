defmodule Monkey.Evaluator.Builtins do
  alias Monkey.Object.Builtin
  alias Monkey.Object.Error
  alias Monkey.Object.Object

  def get("len"), do: %Builtin{fn: &len/1}
  def get(_), do: nil

  def len([arg] = args) when length(args) == 1 do
    case arg do
      %Monkey.Object.String{} ->
        result = String.length(arg.value)
        %Monkey.Object.Integer{value: result}
      %Monkey.Object.Array{} ->
        result = length(arg.elements)
        %Monkey.Object.Integer{value: result}
      _ ->
        error("argument to `len` not supported, got #{Object.type(arg)}")
    end
  end
  def len(args),
    do: error("wrong number of arguments. got=#{length(args)}, want=1")

  defp error(message), do: %Error{message: message}
end
