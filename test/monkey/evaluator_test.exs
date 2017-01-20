defmodule Monkey.EvaluatorTest do
  use ExUnit.Case

  alias Monkey.Ast.Node
  alias Monkey.Evaluator
  alias Monkey.Lexer
  alias Monkey.Object.Boolean
  alias Monkey.Object.Environment
  alias Monkey.Object.Error
  alias Monkey.Object.Function
  alias Monkey.Object.Integer
  alias Monkey.Object.Null
  alias Monkey.Object.String
  alias Monkey.Parser

  def test_eval(input) do
    tokens = Lexer.tokenize(input)
    parser = Parser.from_tokens(tokens)
    {parser, program} = Parser.parse_program(parser)
    env = Environment.build

    assert length(parser.errors) == 0
    {result, _env} = Evaluator.eval(program, env)
    result
  end

  def test_integer_object(object, expected) do
    assert %Integer{} = object
    assert object.value == expected
  end

  def test_boolean_object(object, expected) do
    assert %Boolean{} = object
    assert object.value == expected
  end

  def test_null_object(object) do
    assert %Null{} = object
  end

  test "eval integer expression" do
    values = [
      {"5", 5},
      {"10", 10},
      {"-5", -5},
      {"-10", -10},
      {"5 + 5 + 5 + 5 - 10", 10},
      {"2 * 2 * 2 * 2 * 2", 32},
      {"-50 + 100 + -50", 0},
      {"5 * 2 + 10", 20},
      {"5 + 2 * 10", 25},
      {"20 + 2 * -10", 0},
      {"50 / 2 * 2 + 10", 60},
      {"2 * (5 + 10)", 30},
      {"3 * 3 * 3 + 10", 37},
      {"3 * (3 * 3) + 10", 37},
      {"(5 + 10 * 2 + 15 / 3) * 2 + -10", 50}
    ]

    Enum.each(values, fn({input, expected}) ->
      evaluated = test_eval(input)
      test_integer_object(evaluated, expected)
    end)
  end

  test "eval boolean expression" do
    values = [
      {"true", true},
      {"false", false},
      {"true == true", true},
      {"false == false", true},
      {"true == false", false},
      {"true != false", true},
      {"false != true", true},
      {"(1 < 2) == true", true},
      {"(1 < 2) == false", false},
      {"(1 > 2) == true", false},
      {"(1 > 2) == false", true}
    ]

    Enum.each(values, fn({input, expected}) ->
      evaluated = test_eval(input)
      test_boolean_object(evaluated, expected)
    end)
  end

  test "bang operator" do
    values = [
      {"!true", false},
      {"!false", true},
      {"!5", false},
      {"!!true", true},
      {"!!false", false},
      {"!!5", true},
      {"1 < 2", true},
      {"1 > 2", false},
      {"1 < 1", false},
      {"1 > 1", false},
      {"1 == 1", true},
      {"1 != 1", false},
      {"1 == 2", false},
      {"1 != 2", true}
    ]

    Enum.each(values, fn({input, expected}) ->
      evaluated = test_eval(input)
      test_boolean_object(evaluated, expected)
    end)
  end

  test "if/else expressions" do
    values = [
      {"if (true) { 10 }", 10},
      {"if (false) { 10 }", nil},
      {"if (1) { 10 }", 10},
      {"if (1 < 2) { 10 }", 10},
      {"if (1 > 2) { 10 }", nil},
      {"if (1 > 2) { 10 } else { 20 }", 20},
      {"if (1 < 2) { 10 } else { 20 }", 10}
    ]

    Enum.each(values, fn({input, expected}) ->
      evaluated = test_eval(input)
      if expected do
        test_integer_object(evaluated, expected)
      else
        test_null_object(evaluated)
      end
    end)
  end

  test "return statements" do
    values = [
      {"return 10;", 10},
      {"return 10; 9;", 10},
      {"return 2 * 5; 9;", 10},
      {"9; return 2 * 5; 9;", 10},
      {"""
      if (10 > 1) {
        if (10 > 1) {
          return 10;
        }
        return 1;
      }
      """, 10}
    ]

    Enum.each(values, fn({input, expected}) ->
      evaluated = test_eval(input)
      test_integer_object(evaluated, expected)
    end)
  end

  test "error handling" do
    values = [
      {
        "5 + true;",
        "type mismatch: INTEGER + BOOLEAN",
      },
      {
        "5 + true; 5;",
        "type mismatch: INTEGER + BOOLEAN",
      },
      {
        "-true",
        "unknown operator: -BOOLEAN",
      },
      {
        "true + false;",
        "unknown operator: BOOLEAN + BOOLEAN",
      },
      {
        "5; true + false; 5",
        "unknown operator: BOOLEAN + BOOLEAN",
      },
      {
        "if (10 > 1) { true + false; }",
        "unknown operator: BOOLEAN + BOOLEAN",
      },
      {
        """
        if (10 > 1) {
          if (10 > 1) {
            return true + false;
          }

          return 1;
        }
        """,
        "unknown operator: BOOLEAN + BOOLEAN"
      },
      {
        "foobar",
        "identifier not found: foobar",
      },
      {
        ~s("Hello" - "World"),
        "unknown operator: STRING - STRING"
      }
    ]

    Enum.each(values, fn({input, expected}) ->
      evaluated = test_eval(input)
      assert %Error{} = evaluated
      assert evaluated.message == expected
    end)
  end

  test "let statements" do
    values = [
      {"let a = 5; a;", 5},
      {"let a = 5 * 5; a;", 25},
      {"let a = 5; let b = a; b;", 5},
      {"let a = 5; let b = a; let c = a + b + 5; c;", 15}
    ]

    Enum.each(values, fn({input, expected}) ->
      evaluated = test_eval(input)
      test_integer_object(evaluated, expected)
    end)
  end

  test "function object" do
    input = "fn(x) { x + 2; };"

    function = test_eval(input)
    assert %Function{} = function
    assert length(function.parameters) == 1
    assert Node.to_string(Enum.at(function.parameters, 0)) == "x"
    assert Node.to_string(function.body) == "(x + 2)"
  end

  test "function application" do
    values = [
      {"let identity = fn(x) { x; }; identity(5);", 5},
      {"let identity = fn(x) { return x; }; identity(5);", 5},
      {"let double = fn(x) { x * 2; }; double(5);", 10},
      {"let add = fn(x, y) { x + y; }; add(5, 5);", 10},
      {"let add = fn(x, y) { x + y; }; add(5 + 5, add(5, 5));", 20},
      {"fn(x) { x; }(5)", 5}
    ]

    Enum.each(values, fn({input, expected}) ->
      evaluated = test_eval(input)
      test_integer_object(evaluated, expected)
    end)
  end

  test "closures" do
    input = """
      let newAdder = fn(x) {
        fn(y) { x + y };
      };

      let addTwo = newAdder(2);
      addTwo(2);
    """

    evaluated = test_eval(input)
    test_integer_object(evaluated, 4)
  end

  test "string literal" do
    input = ~s("Hello World!")
    string = test_eval(input)

    assert %String{} = string
    assert string.value == "Hello World!"
  end

  test "string concatenation" do
    input = ~s("Hello" + " " + "World!")
    string = test_eval(input)

    assert %String{} = string
    assert string.value == "Hello World!"
  end

  test "builtin functions" do
    values = [
      {~s/len("")/, 0},
      {~s/len("four")/, 4},
      {~s/len("hello world")/, 11},
      {~s/len(1)/, "argument to `len` not supported, got INTEGER"},
      {~s/len("one", "two")/, "wrong number of arguments. got=2, want=1"}
    ]

    Enum.each(values, fn({input, expected}) ->
      evaluated = test_eval(input)

      cond do
        is_integer(expected) ->
          test_integer_object(evaluated, expected)
        is_bitstring(expected) ->
          assert %Error{} = evaluated
          assert evaluated.message == expected
      end
    end)
  end
end
