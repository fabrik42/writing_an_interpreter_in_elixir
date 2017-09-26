defmodule Mix.Tasks.Repl do
  use Mix.Task
  alias Monkey.Repl

  def run(_) do
    user = "whoami" |> System.cmd([]) |> elem(0) |> String.trim_trailing

    IO.puts("Hello #{user}! This is the Monkey programming language!")
    IO.puts("Feel free to type in commands")
    Repl.loop()
  end
end
