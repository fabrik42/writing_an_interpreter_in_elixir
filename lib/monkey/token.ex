defmodule Monkey.Token do
  @enforce_keys [:type, :literal]
  defstruct [:type, :literal]

  @keywords %{"fn" => :function,
              "let" => :let,
              "true" => :true,
              "false" => :false,
              "if" => :if,
              "else" => :else,
              "return" => :return}

  @types %{illegal: "ILLEGAL",
           eof: "EOF",
           # identifiers and literals
           ident: "IDENT", # add, foobar, x, y, ...
           int: "INT", # 123
           string: "STRING",
           # operators
           assign: "=",
           plus: "+",
           minus: "-",
           bang: "!",
           asterisk: "*",
           slash: "/",
           lt: "<",
           gt: ">",
           eq: "==",
           not_eq: "!=",
           # delimiters
           comma: ",",
           semicolon: ",",
           colon: ":",
           lparen: "(",
           rparen: ")",
           lbrace: "{",
           rbrace: "}",
           lbracket: "[",
           rbracket: "]",
           # keywords
           function: "FUNCTION",
           let: "LET",
           true: "TRUE",
           false: "FALSE",
           if: "IF",
           else: "ELSE",
           return: "RETURN"
  }

  def new([type: type, literal: literal]) when is_atom(type) and is_binary(literal) do
    if Map.has_key?(@types, type) do
      %__MODULE__{type: type, literal: literal}
    else
      raise "Token with type #{inspect(type)} is not defined"
    end
  end

  def lookup_ident(ident) do
    Map.get(@keywords, ident, :ident)
  end
end
