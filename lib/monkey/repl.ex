defmodule Monkey.Repl do
  alias Monkey.Evaluator
  alias Monkey.Lexer
  alias Monkey.Object.Environment
  alias Monkey.Object.Object
  alias Monkey.Parser

  @prompt ">> "

  def loop(env \\ Environment.build) do
    input = IO.gets(@prompt)
    tokens = Lexer.tokenize(input)
    parser = Parser.from_tokens(tokens)
    {parser, program} = Parser.parse_program(parser)

    case length(parser.errors) do
      0 ->
        {result, env} = Evaluator.eval(program, env)
        IO.puts Object.inspect(result)
        loop(env)
      _ ->
        print_parser_errors(parser.errors)
        loop(env)
    end
  end

  defp print_parser_errors(errors) do
    IO.puts "Woops! We ran into some monkey business here!"
    IO.puts "Parser Errors:"
    Enum.each(errors, &IO.puts/1)
  end
end
