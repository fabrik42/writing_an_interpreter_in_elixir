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
           lparen: "(",
           rparen: ")",
           lbrace: "{",
           rbrace: "}",
           # keywords
           function: "FUNCTION",
           let: "LET",
           true: "TRUE",
           false: "FALSE",
           if: "IF",
           else: "ELSE",
           return: "RETURN"
  }

  def lookup_ident(ident) do
    Map.get(@keywords, ident, :ident)
  end
end
