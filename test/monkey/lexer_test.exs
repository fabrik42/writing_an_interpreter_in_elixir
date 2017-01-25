defmodule Monkey.LexerTest do
  use ExUnit.Case

  alias Monkey.Token

  test "converts a string into a list of tokens" do
    input = "=+(){},;"

    expected = [
      %Token{type: :assign, literal: "="},
      %Token{type: :plus, literal: "+"},
      %Token{type: :lparen, literal: "("},
      %Token{type: :rparen, literal: ")"},
      %Token{type: :lbrace, literal: "{"},
      %Token{type: :rbrace, literal: "}"},
      %Token{type: :comma, literal: ","},
      %Token{type: :semicolon, literal: ";"},
      %Token{type: :eof, literal: ""}
    ]

    tokens = Monkey.Lexer.tokenize(input)


    assert length(tokens) == length(expected)

    Enum.zip(expected, tokens)
    |> Enum.each(&(assert elem(&1, 0) == elem(&1, 1)))
  end

  test "converts real monkey code into a list of tokens" do
    input = """
    let five = 5;
    let ten = 10;

    let add = fn(x, y) {
      x + y;
    };

    let result = add(five, ten);
    !-/*5;
    5 < 10 > 5;

    if (5 < 10) {
      return true;
    } else {
      return false;
    }

    10 == 10;
    10 != 9;
    "foobar"
    "foo bar"
    [1, 2];
    {"foo": "bar"}
    """

    expected = [
      %Token{type: :let, literal: "let"},
      %Token{type: :ident, literal: "five"},
      %Token{type: :assign, literal: "="},
      %Token{type: :int, literal: "5"},
      %Token{type: :semicolon, literal: ";"},
      %Token{type: :let, literal: "let"},
      %Token{type: :ident, literal: "ten"},
      %Token{type: :assign, literal: "="},
      %Token{type: :int, literal: "10"},
      %Token{type: :semicolon, literal: ";"},
      %Token{type: :let, literal: "let"},
      %Token{type: :ident, literal: "add"},
      %Token{type: :assign, literal: "="},
      %Token{type: :function, literal: "fn"},
      %Token{type: :lparen, literal: "("},
      %Token{type: :ident, literal: "x"},
      %Token{type: :comma, literal: ","},
      %Token{type: :ident, literal: "y"},
      %Token{type: :rparen, literal: ")"},
      %Token{type: :lbrace, literal: "{"},
      %Token{type: :ident, literal: "x"},
      %Token{type: :plus, literal: "+"},
      %Token{type: :ident, literal: "y"},
      %Token{type: :semicolon, literal: ";"},
      %Token{type: :rbrace, literal: "}"},
      %Token{type: :semicolon, literal: ";"},
      %Token{type: :let, literal: "let"},
      %Token{type: :ident, literal: "result"},
      %Token{type: :assign, literal: "="},
      %Token{type: :ident, literal: "add"},
      %Token{type: :lparen, literal: "("},
      %Token{type: :ident, literal: "five"},
      %Token{type: :comma, literal: ","},
      %Token{type: :ident, literal: "ten"},
      %Token{type: :rparen, literal: ")"},
      %Token{type: :semicolon, literal: ";"},
      %Token{type: :bang, literal: "!"},
      %Token{type: :minus, literal: "-"},
      %Token{type: :slash, literal: "/"},
      %Token{type: :asterisk, literal: "*"},
      %Token{type: :int, literal: "5"},
      %Token{type: :semicolon, literal: ";"},
      %Token{type: :int, literal: "5"},
      %Token{type: :lt, literal: "<"},
      %Token{type: :int, literal: "10"},
      %Token{type: :gt, literal: ">"},
      %Token{type: :int, literal: "5"},
      %Token{type: :semicolon, literal: ";"},
      %Token{type: :if, literal: "if"},
      %Token{type: :lparen, literal: "("},
      %Token{type: :int, literal: "5"},
      %Token{type: :lt, literal: "<"},
      %Token{type: :int, literal: "10"},
      %Token{type: :rparen, literal: ")"},
      %Token{type: :lbrace, literal: "{"},
      %Token{type: :return, literal: "return"},
      %Token{type: :true, literal: "true"},
      %Token{type: :semicolon, literal: ";"},
      %Token{type: :rbrace, literal: "}"},
      %Token{type: :else, literal: "else"},
      %Token{type: :lbrace, literal: "{"},
      %Token{type: :return, literal: "return"},
      %Token{type: :false, literal: "false"},
      %Token{type: :semicolon, literal: ";"},
      %Token{type: :rbrace, literal: "}"},
      %Token{type: :int, literal: "10"},
      %Token{type: :eq, literal: "=="},
      %Token{type: :int, literal: "10"},
      %Token{type: :semicolon, literal: ";"},
      %Token{type: :int, literal: "10"},
      %Token{type: :not_eq, literal: "!="},
      %Token{type: :int, literal: "9"},
      %Token{type: :semicolon, literal: ";"},
      %Token{type: :string, literal: "foobar"},
      %Token{type: :string, literal: "foo bar"},
      %Token{type: :lbracket, literal: "["},
      %Token{type: :int, literal: "1"},
      %Token{type: :comma, literal: ","},
      %Token{type: :int, literal: "2"},
      %Token{type: :rbracket, literal: "]"},
      %Token{type: :semicolon, literal: ";"},
      %Token{type: :lbrace, literal: "{"},
      %Token{type: :string, literal: "foo"},
      %Token{type: :colon, literal: ":"},
      %Token{type: :string, literal: "bar"},
      %Token{type: :rbrace, literal: "}"},
      %Token{type: :eof, literal: ""}
    ]

    tokens = Monkey.Lexer.tokenize(input)

    assert length(tokens) == length(expected)

    Enum.zip(expected, tokens)
    |> Enum.each(&(assert elem(&1, 0) == elem(&1, 1)))
  end
end
