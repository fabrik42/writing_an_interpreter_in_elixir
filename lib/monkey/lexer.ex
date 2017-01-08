defmodule Monkey.Lexer do
  alias Monkey.Token

  def from_string(input) do
    chars = String.split(input, "", trim: true)
    from_string(chars, [])
  end

  defp from_string(_chars = [], tokens) do
    tokens ++ [%Token{type: :eof, literal: ""}]
  end

  defp from_string(chars = [ch | rest], tokens) do
    cond do
      is_whitespace(ch) -> from_string(rest, tokens)
      is_letter(ch) -> read_identifier(chars, tokens)
      is_digit(ch) -> read_number(chars, tokens)
      is_two_char_operator(chars) -> read_two_char_operator(chars, tokens)
      true -> read_next_char(chars, tokens)
    end
  end

  defp read_identifier(chars, tokens) do
    {identifier, rest} = Enum.split_while(chars, &is_letter/1)
    identifier = Enum.join(identifier)
    token = %Token{type: Token.lookup_ident(identifier), literal: identifier}

    from_string(rest, tokens ++ [token])
  end

  defp read_number(chars, tokens) do
    {number, rest} = Enum.split_while(chars, &is_digit/1)
    number = Enum.join(number)
    token = %Token{type: :int, literal: number}

    from_string(rest, tokens ++ [token])
  end

  defp read_two_char_operator(chars, tokens) do
    {literal, rest} = Enum.split(chars, 2)
    literal = Enum.join(literal)
    token = case literal do
      "==" -> %Token{type: :eq, literal: literal}
      "!=" -> %Token{type: :not_eq, literal: literal}
    end

    from_string(rest, tokens ++ [token])
  end

  defp read_next_char(_chars = [ch | rest], tokens) do
    token = case ch do
      "=" -> %Token{type: :assign, literal: ch}
      ";" -> %Token{type: :semicolon, literal: ch}
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
      _ -> %Token{type: :illegal, literal: ""}
    end

    from_string(rest, tokens ++ [token])
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

  defp is_two_char_operator(chars) do
    (Enum.at(chars, 0) == "!" || Enum.at(chars, 0) == "=") && Enum.at(chars, 1) == "="
  end
end
