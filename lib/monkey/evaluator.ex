defmodule Monkey.Evaluator do
  alias Monkey.Ast.{
    ArrayLiteral,
    BlockStatement,
    BooleanLiteral,
    CallExpression,
    ExpressionStatement,
    FunctionLiteral,
    HashLiteral,
    Identifier,
    IfExpression,
    IndexExpression,
    InfixExpression,
    IntegerLiteral,
    LetStatement,
    PrefixExpression,
    Program,
    ReturnStatement,
    StringLiteral
  }
  alias Monkey.Evaluator.Builtins
  alias Monkey.Object.{
    Array,
    Boolean,
    Builtin,
    Environment,
    Error,
    Function,
    Hash,
    Integer,
    Null,
    Object,
    ReturnValue,
    String
  }

  @cached_true %Boolean{value: true}
  @cached_false %Boolean{value: false}
  @cached_null %Null{}

  def eval(%Program{} = ast_node, env), do: eval_program(ast_node, env)
  def eval(%ExpressionStatement{} = ast_node, env), do: eval(ast_node.expression, env)
  def eval(%ReturnStatement{} = ast_node, env) do
    {value, env} = eval(ast_node.return_value, env)
    cond do
      is_error(value) -> {value, env}
      true ->
        value = %ReturnValue{value: value}
        {value, env}
    end
  end
  def eval(%LetStatement{} = ast_node, env) do
    {value, env} = eval(ast_node.value, env)
    cond do
      is_error(value) -> {value, env}
      true ->
        env = Environment.set(env, ast_node.name.value, value)
        {value, env}
    end
  end
  def eval(%IntegerLiteral{} = ast_node, env) do
    value = %Integer{value: ast_node.value}
    {value, env}
  end
  def eval(%BooleanLiteral{} = ast_node, env) do
    value = from_native_bool(ast_node.value)
    {value, env}
  end
  def eval(%StringLiteral{} = ast_node, env) do
    value = %String{value: ast_node.value}
    {value, env}
  end
  def eval(%PrefixExpression{} = ast_node, env) do
    {right, env} = eval(ast_node.right, env)
    cond do
      is_error(right) -> {right, env}
      true ->
        value = eval_prefix_expression(ast_node.operator, right)
        {value, env}
    end
  end
  def eval(%InfixExpression{} = ast_node, env) do
    {left, env} = eval(ast_node.left, env)
    {right, env} = eval(ast_node.right, env)

    cond do
      is_error(left) -> {left, env}
      is_error(right) -> {right, env}
      true ->
        value = eval_infix_expression(ast_node.operator, left, right)
        {value, env}
    end
  end
  def eval(%BlockStatement{} = ast_node, env) do
    eval_block_statement(ast_node, env)
  end
  def eval(%IfExpression{} = ast_node, env) do
    eval_if_expression(ast_node, env)
  end
  def eval(%Identifier{} = ast_node, env) do
    value = Environment.get(env, ast_node.value)
    builtin = Builtins.get(ast_node.value)
    cond do
      value -> {value, env}
      builtin -> {builtin, env}
      true -> {error("identifier not found: #{ast_node.value}"), env}
    end
  end
  def eval(%FunctionLiteral{} = ast_node, env) do
    params = ast_node.parameters
    body = ast_node.body
    value = %Function{parameters: params, body: body, environment: env}
    {value, env}
  end
  def eval(%CallExpression{} = ast_node, env) do
    {function, env} = eval(ast_node.function, env)

    case function do
      %Error{} -> {function, env}
      _ ->
        {args, env} = eval_expressions(ast_node.arguments, env)
        if length(args) == 1 && is_error(Enum.at(args, 0)) do
          value = Enum.at(args, 0)
          {value, env}
        else
          value = apply_function(function, args)
          {value, env}
        end
    end
  end
  def eval(%ArrayLiteral{} = ast_node, env) do
    {elements, env} = eval_expressions(ast_node.elements, env)

    if length(elements) == 1 && is_error(Enum.at(elements, 0)) do
      value = Enum.at(elements, 0)
      {value, env}
    else
      value = %Array{elements: elements}
      {value, env}
    end
  end
  def eval(%IndexExpression{} = ast_node, env) do
    {left, env} = eval(ast_node.left, env)
    {index, env} = eval(ast_node.index, env)

    cond do
      is_error(left) -> {left, env}
      is_error(index) -> {index, env}
      true ->
        value = eval_index_expression(left, index)
        {value, env}
    end
  end
  def eval(%HashLiteral{} = ast_node, env) do
    eval_hash_literal(ast_node, env)
  end

  defp eval_program(program, env, last_evaluated \\ nil) do
    do_eval_program(program.statements, env, last_evaluated)
  end
  defp do_eval_program([], env, last_evaluated), do: {last_evaluated, env}
  defp do_eval_program([statement | rest], env, _evaluated) do
    {value, env} = eval(statement, env)
    case value do
      %ReturnValue{} -> {value.value, env}
      %Error{} -> {value, env}
      _ -> do_eval_program(rest, env, value)
    end
  end

  defp eval_block_statement(block, env, last_evaluated \\ nil) do
    do_eval_block_statement(block.statements, env, last_evaluated)
  end
  defp do_eval_block_statement([], env, last_evaluated), do: {last_evaluated, env}
  defp do_eval_block_statement([statement | rest], env, _last_evaluated) do
    {value, env} = eval(statement, env)

    case value do
      %ReturnValue{} -> {value, env}
      %Error{} -> {value, env}
      _ -> do_eval_block_statement(rest, env, value)
    end
  end

  defp eval_expressions(expressions, env) do
    {evaluated, env} = Enum.reduce_while(expressions, {[], env}, fn(expression, {acc, env}) ->
      {value, env} = eval(expression, env)
      case value do
        %Error{} -> {:halt, {value, env}}
        _ -> {:cont, {[value | acc], env}}
      end
    end)

    evaluated = Enum.reverse(evaluated)
    {evaluated, env}
  end

  defp eval_prefix_expression(operator, right) do
    case operator do
      "!" -> eval_bang_operator_expression(right)
      "-" -> eval_minus_operator_expression(right)
      _ -> error("unknown operator: #{operator}#{Object.type(right)}")
    end
  end

  defp eval_bang_operator_expression(right) do
    case right do
      @cached_true -> @cached_false
      @cached_false -> @cached_true
      @cached_null -> @cached_true
      _ -> @cached_false
    end
  end

  defp eval_minus_operator_expression(right) do
    case right do
      %Integer{} -> %Integer{value: -right.value}
      _ -> error("unknown operator: -#{Object.type(right)}")
    end
  end

  defp eval_infix_expression(operator, %Integer{} = left, %Integer{} = right),
    do: eval_integer_infix_expression(operator, left, right)
  defp eval_infix_expression(operator, %String{} = left, %String{} = right),
    do: eval_string_infix_expression(operator, left, right)
  defp eval_infix_expression("==", left, right),
    do: from_native_bool(left == right)
  defp eval_infix_expression("!=", left, right),
    do: from_native_bool(left != right)
  defp eval_infix_expression(operator, left, right) do
    left_type = Object.type(left)
    right_type = Object.type(right)

    message = if left_type != right_type do
      "type mismatch: #{left_type} #{operator} #{right_type}"
    else
      "unknown operator: #{left_type} #{operator} #{right_type}"
    end

    error(message)
  end

  defp eval_integer_infix_expression(operator, left, right) do
    case operator do
      "+" -> %Integer{value: left.value + right.value}
      "-" -> %Integer{value: left.value - right.value}
      "*" -> %Integer{value: left.value * right.value}
      "/" -> %Integer{value: round(left.value / right.value)}
      "<" -> from_native_bool(left.value < right.value)
      ">" -> from_native_bool(left.value > right.value)
      "==" -> from_native_bool(left.value == right.value)
      "!=" -> from_native_bool(left.value != right.value)
      _ -> error("unknown operator: #{Object.type(left)} #{operator} #{Object.type(right)}")
    end
  end

  defp eval_string_infix_expression(operator, left, right) do
    case operator do
      "+" -> %String{value: left.value <> right.value}
      _ -> error("unknown operator: #{Object.type(left)} #{operator} #{Object.type(right)}")
    end
  end

  defp eval_if_expression(expression, env) do
    {condition, env} = eval(expression.condition, env)

    cond do
      is_error(condition) -> {condition, env}
      is_truthy(condition) -> eval(expression.consequence, env)
      expression.alternative != nil -> eval(expression.alternative, env)
      true -> {@cached_null, env}
    end
  end

  defp eval_index_expression(%Array{} = left, %Integer{} = index),
    do: eval_array_index_expression(left, index)
  defp eval_index_expression(%Hash{} = left, index),
    do: eval_hash_index_expression(left, index)
  defp eval_index_expression(left, _),
    do: error("index operator not supported: #{Object.type(left)}")

  defp eval_array_index_expression(array, index) do
    idx = index.value

    cond do
      idx < 0 -> @cached_null
      true -> Enum.at(array.elements, idx, @cached_null)
    end
  end

  defp eval_hash_index_expression(hash, index) do
    key = Hash.Hashable.hash(index)

    pair = cond do
      is_error(key) -> error("unusable as hash key: #{Object.type(index)}")
      true -> Map.get(hash.pairs, key, @cached_null)
    end

    case pair do
      %Error{} -> pair
      @cached_null -> pair
      _ -> pair.value
    end
  end

  defp eval_hash_literal(ast_node, env) do
    pairs = Map.to_list(ast_node.pairs)
    eval_hash_pair(pairs, env, %{})
  end

  defp eval_hash_pair([] = _pairs, env, evaluated_pairs) do
    hash = %Hash{pairs: evaluated_pairs}
    {hash, env}
  end
  defp eval_hash_pair([pair | rest] = _pairs, env, evaluated_pairs) do
    {key, value} = pair

    {key, env} = eval(key, env)
    {value, env} = eval(value, env)
    hash_key = Hash.Hashable.hash(key)

    cond do
      is_error(key) -> {key, env}
      is_error(value) -> {value, env}
      is_error(hash_key) -> {hash_key, env}
      true ->
        hash_pair = %Hash.Pair{key: key, value: value}
        evaluated_pairs = Map.put(evaluated_pairs, hash_key, hash_pair)
        eval_hash_pair(rest, env, evaluated_pairs)
    end
  end

  defp apply_function(%Function{} = function, args) do
    extended_env = extended_function_env(function, args)
    {value, _env} = eval(function.body, extended_env)
    unwrap_return_value(value)
  end
  defp apply_function(%Builtin{} = function, args), do: function.fn.(args)
  defp apply_function(function, _),
    do: error("not a function: #{Object.type(function)}")

  defp extended_function_env(function, args) do
    env = Environment.build_enclosed(function.environment)
    pairs = Enum.zip(function.parameters, args)

    List.foldl(pairs, env, fn({identifier, arg}, env) ->
      Environment.set(env, identifier.value, arg)
    end)
  end

  defp unwrap_return_value(obj) do
    case obj do
      %ReturnValue{} -> obj.value
      _ -> obj
    end
  end

  defp is_truthy(obj) do
    case obj do
      @cached_true -> true
      @cached_false -> false
      @cached_null -> false
      _ -> true
    end
  end

  defp is_error(%Error{}), do: true
  defp is_error(_), do: false

  defp error(message), do: %Error{message: message}

  defp from_native_bool(:true), do: @cached_true
  defp from_native_bool(:false), do: @cached_false
end
