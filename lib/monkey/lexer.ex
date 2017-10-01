defmodule Monkey.Lexer do
  import Monkey.Qualifiers
  alias Monkey.Token

  def tokenize(input) do
    tokenize(input, [])
  end

  defp tokenize("", tokens) do
    Enum.reverse([Token.new(type: :eof, literal: "") | tokens])
  end
  defp tokenize("==" <> rest, tokens) do
    tokenize(rest, [%Token{type: :eq, literal: "=="} | tokens])
  end
  defp tokenize("!=" <> rest, tokens) do
    tokenize(rest, [%Token{type: :not_eq, literal: "!="} | tokens])
  end
  defp tokenize(<<char::binary-size(1), rest::binary>>, tokens) when is_whitespace(char) do
    tokenize(rest, tokens)
  end
  defp tokenize(<<char::binary-size(1), _::binary>> = input, tokens) when is_letter(char) do
    read_identifier(input, tokens)
  end
  defp tokenize(<<char::binary-size(1), _::binary>> = input, tokens) when is_digit(char) do
    read_number(input, tokens)
  end
  defp tokenize(<<char::binary-size(1), _::binary>> = input, tokens) when is_quote(char) do
    read_string(input, tokens)
  end
  defp tokenize(input, tokens) do
    read_next_char(input, tokens)
  end

  defp read_identifier(input, tokens) do
    {identifier, rest} = read_sequence(input, &is_letter/1)
    token = Token.new(type: Token.lookup_ident(identifier), literal: identifier)

    tokenize(rest, [token | tokens])
  end

  defp read_number(input, tokens) do
    {number, rest} = read_sequence(input, &is_digit/1)
    token = Token.new(type: :int, literal: number)

    tokenize(rest, [token | tokens])
  end

  def read_string("\"" <> rest, tokens) do
    {string, "\"" <> rest} = read_sequence(rest, &(!is_quote(&1)))
    token = Token.new(type: :string, literal: string)

    tokenize(rest, [token | tokens])
  end

  defp read_sequence(input, fun, acc \\ "")
  defp read_sequence("", _fun, acc), do: {acc, ""}
  defp read_sequence(<<char::binary-size(1), rest::binary>> = input, fun, acc) do
    if fun.(char) do
      read_sequence(rest, fun, acc <> char)
    else
      {acc, input}
    end
  end

  defp read_next_char(<<ch::binary-size(1), rest::binary>>, tokens) do
    token = case ch do
      "=" -> Token.new(type: :assign, literal: ch)
      ";" -> Token.new(type: :semicolon, literal: ch)
      ":" -> Token.new(type: :colon, literal: ch)
      "(" -> Token.new(type: :lparen, literal: ch)
      ")" -> Token.new(type: :rparen, literal: ch)
      "+" -> Token.new(type: :plus, literal: ch)
      "-" -> Token.new(type: :minus, literal: ch)
      "!" -> Token.new(type: :bang, literal: ch)
      "*" -> Token.new(type: :asterisk, literal: ch)
      "/" -> Token.new(type: :slash, literal: ch)
      "<" -> Token.new(type: :lt, literal: ch)
      ">" -> Token.new(type: :gt, literal: ch)
      "," -> Token.new(type: :comma, literal: ch)
      "{" -> Token.new(type: :lbrace, literal: ch)
      "}" -> Token.new(type: :rbrace, literal: ch)
      "[" -> Token.new(type: :lbracket, literal: ch)
      "]" -> Token.new(type: :rbracket, literal: ch)
      _ -> Token.new(type: :illegal, literal: "")
    end

    tokenize(rest, [token | tokens])
  end
end
