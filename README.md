# Writing An Interpreter In Elixir

An interpreter for the Monkey programming language as known from the book [Writing An Interpreter In Go](https://interpreterbook.com/), but this time implemented in Elixir, using only the stdlib.

## Starting the REPL

There is a handy mix task to start a Monkey REPL

```
mix repl
```

## Running the tests

```
mix test
```

## Notable changes to the original Golang implementation

### Lexer

* Does not maintain state and is implemented using recursive function calls.

## TODOs

* Check code quality, Elixir ways of doing things
* Add credo
* Add CI
* Maybe more builtin functions
