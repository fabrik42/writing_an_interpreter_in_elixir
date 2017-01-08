defmodule Mix.Tasks.Repl do
  use Mix.Task

  def run(_) do
    user = System.cmd("whoami", []) |> elem(0) |> String.rstrip

    IO.puts("Hello #{user}! This is the Monkey programming language!")
    IO.puts("Feel free to type in commands")
    Monkey.Repl.loop()
  end
end
