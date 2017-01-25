# Writing An Interpreter In Elixir

[![Build Status](https://travis-ci.org/fabrik42/writing_an_interpreter_in_elixir.svg?branch=master)](https://travis-ci.org/fabrik42/writing_an_interpreter_in_elixir)

---

## Introduction

This project is an interpreter for the [Monkey](https://interpreterbook.com/index.html#the-monkey-programming-language) programming language, featuring its own lexer, AST producing parser and evaluator. The Monkey programming language as well as the structure of the interpreter are based on the book [Writing An Interpreter In Go](https://interpreterbook.com/). 

I really enjoyed reading this book and following the implementation of the interpreter in Go, because it was built using simple and straightforward patterns. You learn to build an interpreter completely by yourself, no generators, no external dependencies, just you and your code. :)

And even though - at first sight - an interpreter seems to be a big, hairy, complex machine, the author manages to implement a fully working version using easy to understand code.

Patterns like early returns, simple for-loops and small amounts of well encapsulated state are well known to most programmers and easy to reason about.

However, none of these things exist in Elixir and I was looking to get my hands dirty with this language. So I decided to implement the interpreter for Monkey in Elixir instead of Go, to see which other patterns can be applied to solve the problems with a more functional approach.

I know that there are way more sophisticated patterns in functional languages, like monads, but I wanted to solve this problem using only the standard lib of Elixir. First of all, because the reference implementation in Golang did the same and second, because I wanted to dive deeper into the standard lib.

It is important to keep in mind, that the whole basic structure of the interpreter is derived from the original Golang book. So maybe there are even better ways to lay out an interpreter in Elixir. If this is the case, let me know! :)

The code in this repository is the current state of this interpreter. It is fully functional, tested and I tried my best to implement it using Elixir best practices. There are still some rough edges and I think there is still a lot to learn for me, about Elixir and functional programming in general.

You are very welcome to walk through this code and if you spot something that could be done better, [please let me know](https://github.com/fabrik42/writing_an_interpreter_in_elixir/issues/new).

## Monkey Language Features

A list of language features can be found [here](https://interpreterbook.com/index.html#the-monkey-programming-language).

You should be able to try them all out in the REPL (see below).

## Usage

This project only uses the stdlib of Elixir, so no `mix deps.get` is necessary.

### Starting the REPL

There is a handy mix task to start a Monkey REPL so you can play around with the language.

```
mix repl
```

### Running the tests

```
mix test
```

## Notable changes to the original Golang implementation

### Token

* Does not use constants but atoms to specify a token type.

### Lexer

* Does not maintain state and is implemented using recursive function calls.

### Parser

* Prefix parse functions are defined using pattern matching in function calls instead of a lookup table with functions as values and extra nil handling.

### Evaluator

* As the evaluator is stateless, it will not only output the evaluated result, but also the environment that was used to evaluate the code (defined variables).
* As a consequence, the evaluator will also be called with an environment to work with, so it can resume working in the same environment (see REPL).

## TODOs

* Check code quality, Elixir ways of doing things
* Add Typespecs and Dialyzer for static analysis
* Try to remove TODOs aka nested conditions
* Maybe more builtin functions
