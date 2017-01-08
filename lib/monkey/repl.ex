defmodule Monkey.Repl do
  alias Monkey.Lexer

  @prompt ">> "

  def loop() do
    input = IO.gets(@prompt)
    tokens = Lexer.from_string(input)
    IO.inspect(tokens)

    loop()
  end
end
