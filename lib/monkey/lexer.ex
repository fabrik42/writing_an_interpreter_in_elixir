defmodule Monkey.Lexer do
  alias Monkey.Token

  def tokenize(input) do
    chars = String.split(input, "", trim: true)
    tokenize(chars, [])
  end

  @spec tokenize(any, any) :: [Token.t]
  defp tokenize(_chars = [], tokens) do
    Enum.reverse([%Token{type: :eof, literal: ""} | tokens])
  end

  defp tokenize(chars = [ch | rest], tokens) do
    cond do
      is_whitespace(ch) -> tokenize(rest, tokens)
      is_letter(ch) -> read_identifier(chars, tokens)
      is_digit(ch) -> read_number(chars, tokens)
      is_two_char_operator(chars) -> read_two_char_operator(chars, tokens)
      is_quote(ch) -> read_string(chars, tokens)
      true -> read_next_char(chars, tokens)
    end
  end

  defp read_identifier(chars, tokens) do
    {identifier, rest} = Enum.split_while(chars, &is_letter/1)
    identifier = Enum.join(identifier)
    token = %Token{type: Token.lookup_ident(identifier), literal: identifier}

    tokenize(rest, [token | tokens])
  end

  defp read_number(chars, tokens) do
    {number, rest} = Enum.split_while(chars, &is_digit/1)
    number = Enum.join(number)
    token = %Token{type: :int, literal: number}

    tokenize(rest, [token | tokens])
  end

  defp read_two_char_operator(chars, tokens) do
    {literal, rest} = Enum.split(chars, 2)
    literal = Enum.join(literal)
    token = case literal do
      "==" -> %Token{type: :eq, literal: literal}
      "!=" -> %Token{type: :not_eq, literal: literal}
    end

    tokenize(rest, [token | tokens])
  end

  def read_string([_quote | rest], tokens) do
    {string, [_quote | rest]} = Enum.split_while(rest, &(!is_quote(&1)))
    string = Enum.join(string)
    token = %Token{type: :string, literal: string}

    tokenize(rest, [token | tokens])
  end

  defp read_next_char(_chars = [ch | rest], tokens) do
    token = case ch do
      "=" -> %Token{type: :assign, literal: ch}
      ";" -> %Token{type: :semicolon, literal: ch}
      ":" -> %Token{type: :colon, literal: ch}
      "(" -> %Token{type: :lparen, literal: ch}
      ")" -> %Token{type: :rparen, literal: ch}
      "+" -> %Token{type: :plus, literal: ch}
      "-" -> %Token{type: :minus, literal: ch}
      "!" -> %Token{type: :bang, literal: ch}
      "*" -> %Token{type: :asterisk, literal: ch}
      "/" -> %Token{type: :slash, literal: ch}
      "<" -> %Token{type: :lt, literal: ch}
      ">" -> %Token{type: :gt, literal: ch}
      "," -> %Token{type: :comma, literal: ch}
      "{" -> %Token{type: :lbrace, literal: ch}
      "}" -> %Token{type: :rbrace, literal: ch}
      "[" -> %Token{type: :lbracket, literal: ch}
      "]" -> %Token{type: :rbracket, literal: ch}
      _ -> %Token{type: :illegal, literal: ""}
    end

    tokenize(rest, [token | tokens])
  end

  defp is_letter(ch) do
    "a" <= ch && ch <= "z" || "A" <= ch && ch <= "Z" || ch == "_"
  end

  defp is_digit(ch) do
    "0" <= ch && ch <= "9"
  end

  defp is_whitespace(ch) do
    ch == " " || ch == "\n" || ch == "\t"
  end

  defp is_quote(ch), do: ch == "\""

  defp is_two_char_operator(chars) do
    (Enum.at(chars, 0) == "!" || Enum.at(chars, 0) == "=") && Enum.at(chars, 1) == "="
  end
end
