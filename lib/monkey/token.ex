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
  @type_keys Map.keys(@types)

  def new([type: type, literal: literal]) when type in @type_keys do
    %__MODULE__{type: type, literal: literal}
  end

  def lookup_ident(ident) do
    Map.get(@keywords, ident, :ident)
  end
end
