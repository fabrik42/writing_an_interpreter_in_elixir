defmodule Mix.Tasks.Repl do
  use Mix.Task

  def run(_) do
    Monkey.Repl.loop()
  end
end
