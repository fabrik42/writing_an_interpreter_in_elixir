defmodule Monkey.Qualifiers do
  defmacro is_whitespace(ch) do
    quote do
      unquote(ch) == " " or unquote(ch) == "\n" or unquote(ch) == "\t"
    end
  end

  defmacro is_letter(ch) do
    quote do
      "a" <= unquote(ch) and unquote(ch) <= "z" or
        "A" <= unquote(ch) and unquote(ch) <= "Z" or
        unquote(ch) == "_"
    end
  end

  defmacro is_digit(ch) do
    quote do
      "0" <= unquote(ch) and unquote(ch) <= "9"
    end
  end

  defmacro is_quote(ch) do
    quote do
      unquote(ch) == "\""
    end
  end
end
