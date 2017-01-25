defmodule Monkey.ParserTest do
  use ExUnit.Case
  alias Monkey.Ast.ArrayLiteral
  alias Monkey.Ast.BooleanLiteral
  alias Monkey.Ast.CallExpression
  alias Monkey.Ast.ExpressionStatement
  alias Monkey.Ast.FunctionLiteral
  alias Monkey.Ast.HashLiteral
  alias Monkey.Ast.Identifier
  alias Monkey.Ast.IfExpression
  alias Monkey.Ast.IndexExpression
  alias Monkey.Ast.InfixExpression
  alias Monkey.Ast.IntegerLiteral
  alias Monkey.Ast.LetStatement
  alias Monkey.Ast.Node
  alias Monkey.Ast.PrefixExpression
  alias Monkey.Ast.Program
  alias Monkey.Ast.ReturnStatement
  alias Monkey.Ast.StringLiteral
  alias Monkey.Lexer
  alias Monkey.Parser

  def test_literal_expression(expression, value) do
    case value do
      v when is_integer(v) -> test_integer_literal(expression, v)
      v when is_boolean(v) -> test_boolean_literal(expression, v)
      v when is_bitstring(v) -> test_identifier(expression, v)
    end
  end

  def test_let_statement(statement, name) do
    assert %LetStatement{} = statement
    assert Node.token_literal(statement) == "let"
    assert statement.name.value == name
    assert Node.token_literal(statement.name) == name
  end

  def test_integer_literal(expression, value) do
    assert %IntegerLiteral{} = expression
    assert expression.value == value
    assert Node.token_literal(expression) == Integer.to_string(value)
  end

  def test_identifier(expression, value) do
    assert %Identifier{} = expression
    assert expression.value == value
    assert Node.token_literal(expression) == value
  end

  def test_boolean_literal(expression, value) do
    assert %BooleanLiteral{} = expression
    assert expression.value == value
    assert Node.token_literal(expression) == Atom.to_string(value)
  end

  def test_infix_expression(expression, left, operator, right) do
    assert %InfixExpression{} = expression
    test_literal_expression(expression.left, left)
    assert expression.operator == operator
    test_literal_expression(expression.right, right)
  end

  def parse_input(input) do
    tokens = Lexer.tokenize(input)
    parser = Parser.from_tokens(tokens)
    {parser, program} = Parser.parse_program(parser)

    if length(parser.errors) > 0, do: IO.inspect(parser.errors)
    assert length(parser.errors) == 0

    {parser, program}
  end

  def parse_one_expression_statement(input) do
    {_, program} = parse_input(input)
    assert length(program.statements) == 1

    statement = Enum.at(program.statements, 0)
    assert %ExpressionStatement{} = statement
    statement
  end

  test "parse let statements" do
    values = [
      {"let x = 5;", "x", 5},
		  {"let y = true;", "y", true},
		  {"let foobar = y", "foobar", "y"},
    ]

    Enum.each(values, fn({input, identifier, value}) ->
      {_, program} = parse_input(input)
      assert length(program.statements) == 1

      statement = Enum.at(program.statements, 0)
      test_let_statement(statement, identifier)
      test_literal_expression(statement.value, value)
    end)
  end

  test "parse return statements" do
    values = [
		  {"return 5;", 5},
		  {"return true;", true},
		  {"return foobar;", "foobar"}
    ]

    Enum.each(values, fn({input, value}) ->
      {_, program} = parse_input(input)
      assert length(program.statements) == 1

      statement = Enum.at(program.statements, 0)
      assert %ReturnStatement{} = statement
      assert Node.token_literal(statement) == "return"

      test_literal_expression(statement.return_value, value)
    end)
  end

  test "parse identifier expression" do
    input = "foobar;"
    statement = parse_one_expression_statement(input)

    identifier = statement.expression
    test_identifier(identifier, "foobar")
  end

  test "parse integer literal expression" do
    input = "5;"
    statement = parse_one_expression_statement(input)

    literal = statement.expression
    test_integer_literal(literal, 5)
  end

  test "parse prefix expressions" do
    values = [
      {"!5;", "!", 5},
      {"-15", "-", 15},
      {"!foobar;", "!", "foobar"},
		  {"-foobar;", "-", "foobar"},
		  {"!true;", "!", true},
		  {"!false;", "!", false}
    ]

    Enum.each(values, fn({input, operator, value}) ->
      statement = parse_one_expression_statement(input)

      expression = statement.expression
      assert %PrefixExpression{} = expression

      assert expression.operator == operator
      test_literal_expression(expression.right, value)
    end)
  end

  test "parse infix expressions" do
    values = [
      {"5 + 5;", 5, "+", 5},
      {"5 - 5;", 5, "-", 5},
      {"5 * 5;", 5, "*", 5},
      {"5 / 5;", 5, "/", 5},
      {"5 > 5;", 5, ">", 5},
      {"5 < 5;", 5, "<", 5},
      {"5 == 5;", 5, "==", 5},
      {"5 != 5;", 5, "!=", 5},
      {"foobar + barfoo;", "foobar", "+", "barfoo"},
		  {"foobar - barfoo;", "foobar", "-", "barfoo"},
		  {"foobar * barfoo;", "foobar", "*", "barfoo"},
		  {"foobar / barfoo;", "foobar", "/", "barfoo"},
		  {"foobar > barfoo;", "foobar", ">", "barfoo"},
		  {"foobar < barfoo;", "foobar", "<", "barfoo"},
		  {"foobar == barfoo;", "foobar", "==", "barfoo"},
		  {"foobar != barfoo;", "foobar", "!=", "barfoo"},
		  {"true == true", true, "==", true},
		  {"true != false", true, "!=", false},
		  {"false == false", false, "==", false}
    ]

    Enum.each(values, fn({input, left, operator, right}) ->
      statement = parse_one_expression_statement(input)

      expression = statement.expression
      test_infix_expression(expression, left, operator, right)
    end)
  end

  test "operator precedence parsing" do
    values = [
      {"-a * b", "((-a) * b)"},
      {"!-a", "(!(-a))"},
		  {"a + b + c", "((a + b) + c)"},
		  {"a + b - c", "((a + b) - c)"},
		  {"a * b * c", "((a * b) * c)"},
		  {"a * b / c", "((a * b) / c)"},
		  {"a + b / c", "(a + (b / c))"},
      {"a + b * c + d / e - f", "(((a + (b * c)) + (d / e)) - f)"},
		  {"3 + 4; -5 * 5", "(3 + 4)((-5) * 5)"},
		  {"5 > 4 == 3 < 4", "((5 > 4) == (3 < 4))"},
		  {"5 < 4 != 3 > 4", "((5 < 4) != (3 > 4))"},
		  {"3 + 4 * 5 == 3 * 1 + 4 * 5", "((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))"},
		  {"3 + 4 * 5 == 3 * 1 + 4 * 5", "((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))"},
		  {"true", "true"},
		  {"false", "false"},
		  {"3 > 5 == false", "((3 > 5) == false)"},
		  {"3 < 5 == true", "((3 < 5) == true)"},
		  {"1 + (2 + 3) + 4", "((1 + (2 + 3)) + 4)"},
		  {"(5 + 5) * 2", "((5 + 5) * 2)"},
		  {"2 / (5 + 5)", "(2 / (5 + 5))"},
		  {"(5 + 5) * 2 * (5 + 5)", "(((5 + 5) * 2) * (5 + 5))"},
		  {"-(5 + 5)", "(-(5 + 5))"},
		  {"!(true == true)", "(!(true == true))"},
		  {"a + add(b * c) + d", "((a + add((b * c))) + d)"},
		  {"add(a, b, 1, 2 * 3, 4 + 5, add(6, 7 * 8))", "add(a, b, 1, (2 * 3), (4 + 5), add(6, (7 * 8)))"},
		  {"add(a + b + c * d / f + g)", "add((((a + b) + ((c * d) / f)) + g))"},
      {"a * [1, 2, 3, 4][b * c] * d", "((a * ([1, 2, 3, 4][(b * c)])) * d)"},
      {"add(a * b[2], b[1], 2 * [1, 2][1])", "add((a * (b[2])), (b[1]), (2 * ([1, 2][1])))"}
    ]

    Enum.each(values, fn({input, expected}) ->
      {_, program} = parse_input(input)
      assert Program.to_string(program) == expected
    end)
  end

  test "parse boolean expressions" do
    values = [
      {"true", true},
      {"false", false}
    ]

    Enum.each(values, fn({input, value}) ->
      statement = parse_one_expression_statement(input)

      boolean = statement.expression
      assert %BooleanLiteral{} = boolean
      assert boolean.value == value
    end)
  end

  test "parse if expression" do
    input = "if (x < y) { x }"
    statement = parse_one_expression_statement(input)

    expression = statement.expression
    assert %IfExpression{} = expression
    test_infix_expression(expression.condition, "x", "<", "y")

    assert length(expression.consequence.statements) == 1
    consequence = Enum.at(expression.consequence.statements, 0)
    test_identifier(consequence.expression, "x")

    assert expression.alternative == nil
  end

  test "parse if/else expression" do
    input = "if (x < y) { x } else { y }"
    statement = parse_one_expression_statement(input)

    expression = statement.expression
    assert %IfExpression{} = expression
    test_infix_expression(expression.condition, "x", "<", "y")

    assert length(expression.consequence.statements) == 1
    consequence = Enum.at(expression.consequence.statements, 0)
    assert %ExpressionStatement{} = consequence
    test_identifier(consequence.expression, "x")

    assert length(expression.alternative.statements) == 1
    alternative = Enum.at(expression.alternative.statements, 0)
    assert %ExpressionStatement{} = alternative
    test_identifier(alternative.expression, "y")
  end

  test "parse function literal" do
    input = "fn(x, y) { x + y; }"
    statement = parse_one_expression_statement(input)

    function = statement.expression
    assert %FunctionLiteral{} = function

    assert length(function.parameters) == 2
    test_literal_expression(Enum.at(function.parameters, 0), "x")
    test_literal_expression(Enum.at(function.parameters, 1), "y")

    assert length(function.body.statements) == 1
    body_statement = Enum.at(function.body.statements, 0)
    test_infix_expression(body_statement.expression, "x", "+", "y")
  end

  test "parse function parameters" do
    values = [
      {"fn() {};", []},
      {"fn(x) {};", ["x"]},
      {"fn(x, y, z) {};", ["x", "y", "z"]}
    ]

    Enum.each(values, fn({input, parameters}) ->
      statement = parse_one_expression_statement(input)

      function = statement.expression
      assert %FunctionLiteral{} = function

      assert length(function.parameters) == length(parameters)

      Enum.zip(function.parameters, parameters)
      |> Enum.each(fn({identifier, expected}) ->
        test_literal_expression(identifier, expected)
      end)
    end)
  end

  test "parse call expression" do
    input = "add(1, 2 * 3, 4 + 5);"
    statement = parse_one_expression_statement(input)

    expression = statement.expression
    assert %CallExpression{} = expression

    test_identifier(expression.function, "add")

    assert length(expression.arguments) == 3
    test_literal_expression(Enum.at(expression.arguments, 0), 1)
    test_infix_expression(Enum.at(expression.arguments, 1), 2, "*", 3)
    test_infix_expression(Enum.at(expression.arguments, 2), 4, "+", 5)
  end

  test "parse string literal expression" do
    input = ~s{"hello world\";}
    statement = parse_one_expression_statement(input)

    expression = statement.expression
    assert %StringLiteral{} = expression
    assert expression.value == "hello world"
  end

  test "parse empty array literal" do
    input = "[]"
    statement = parse_one_expression_statement(input)

    array = statement.expression
    assert %ArrayLiteral{} = array
    assert length(array.elements) == 0
  end

  test "parse array literal" do
    input = "[1, 2 + 2, 3 * 3]"
    statement = parse_one_expression_statement(input)

    array = statement.expression
    assert %ArrayLiteral{} = array
    assert length(array.elements) == 3

    test_integer_literal(Enum.at(array.elements, 0), 1)
    test_infix_expression(Enum.at(array.elements, 1), 2, "+", 2)
    test_infix_expression(Enum.at(array.elements, 2), 3, "*", 3)
  end

  test "parse index expression" do
    input = "myArray[1 + 1]"
    statement = parse_one_expression_statement(input)

    index = statement.expression
    assert %IndexExpression{} = index
    test_identifier(index.left, "myArray")
    test_infix_expression(index.index, 1, "+", 1)
  end

  test "parse hash literal" do
    input = ~s/{"one": 1, "two": 2, "three": 3}/
    statement = parse_one_expression_statement(input)

    hash = statement.expression
    assert %HashLiteral{} = hash
    assert length(Map.keys(hash.pairs)) == 3

    expected = %{
      "one" => 1,
      "two" => 2,
      "three" => 3
    }

    Enum.each(hash.pairs, fn({key, value})->
      assert %StringLiteral{} = key
      expected_value = expected[Node.to_string(key)]

      test_integer_literal(value, expected_value)
    end)
  end

  test "parse empty hash literal" do
    input = "{}"
    statement = parse_one_expression_statement(input)

    hash = statement.expression
    assert %HashLiteral{} = hash

    assert length(Map.keys(hash.pairs)) == 0
  end

  test "parse hash literal with boolean keys" do
    input = "{true: 1, false: 2}"
    statement = parse_one_expression_statement(input)

    hash = statement.expression
    assert %HashLiteral{} = hash
    assert length(Map.keys(hash.pairs)) == 2

    expected = %{
      "true" => 1,
      "false" => 2
    }

    Enum.each(hash.pairs, fn({key, value})->
      assert %BooleanLiteral{} = key
      expected_value = expected[Node.to_string(key)]

      test_integer_literal(value, expected_value)
    end)
  end

  test "parse hash literal with integer keys" do
    input = "{1: 1, 2: 2, 3: 3}"
    statement = parse_one_expression_statement(input)

    hash = statement.expression
    assert %HashLiteral{} = hash
    assert length(Map.keys(hash.pairs)) == 3

    expected = %{
      "1" => 1,
      "2" => 2,
      "3" => 3
    }

    Enum.each(hash.pairs, fn({key, value})->
      assert %IntegerLiteral{} = key
      expected_value = expected[Node.to_string(key)]

      test_integer_literal(value, expected_value)
    end)
  end

  test "parse hash literal with expressions" do
    input = ~s({"one": 0 + 1, "two": 10 - 8, "three": 15 / 5})
    statement = parse_one_expression_statement(input)

    hash = statement.expression
    assert %HashLiteral{} = hash
    assert length(Map.keys(hash.pairs)) == 3

    expected = %{
      "one" => &(test_infix_expression(&1, 0, "+", 1)),
      "two" => &(test_infix_expression(&1, 10, "-", 8)),
      "three" => &(test_infix_expression(&1, 15, "/", 5))
    }

    Enum.each(hash.pairs, fn({key, value})->
      assert %StringLiteral{} = key
      test_fn = expected[Node.to_string(key)]
      test_fn.(value)
    end)
  end
end
