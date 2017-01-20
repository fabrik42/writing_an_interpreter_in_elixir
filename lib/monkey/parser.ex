defmodule Monkey.Parser do
  alias Monkey.Ast.ArrayLiteral
  alias Monkey.Ast.BlockStatement
  alias Monkey.Ast.Boolean
  alias Monkey.Ast.CallExpression
  alias Monkey.Ast.ExpressionStatement
  alias Monkey.Ast.FunctionLiteral
  alias Monkey.Ast.Identifier
  alias Monkey.Ast.IfExpression
  alias Monkey.Ast.IndexExpression
  alias Monkey.Ast.InfixExpression
  alias Monkey.Ast.IntegerLiteral
  alias Monkey.Ast.LetStatement
  alias Monkey.Ast.PrefixExpression
  alias Monkey.Ast.Program
  alias Monkey.Ast.ReturnStatement
  alias Monkey.Ast.StringLiteral
  alias Monkey.Parser
  alias Monkey.Token

  @enforce_keys [:curr, :peek, :tokens, :errors]
  defstruct [:curr, :peek, :tokens, :errors]

  @precedence_levels %{
    lowest: 0,
    equals: 1,
    less_greater: 2,
    sum: 3,
    product: 4,
    prefix: 5,
    call: 6,
    index: 7
  }

  @precedences %{
    eq: @precedence_levels.equals,
    not_eq: @precedence_levels.equals,
    lt: @precedence_levels.less_greater,
    gt: @precedence_levels.less_greater,
    plus: @precedence_levels.sum,
    minus: @precedence_levels.sum,
    slash: @precedence_levels.product,
    asterisk: @precedence_levels.product,
    lparen: @precedence_levels.call,
    lbracket: @precedence_levels.index
  }

  def from_tokens(tokens) do
    [curr | [peek | rest]] = tokens
    %Parser{curr: curr, peek: peek, tokens: rest, errors: []}
  end

  def parse_program(p, statements \\ []), do: do_parse_program(p, statements)
  defp do_parse_program(%Parser{curr: %Token{type: :eof}} = p, statements) do
    program = %Program{statements: statements}
    {p, program}
  end
  defp do_parse_program(%Parser{} = p, statements) do
    {p, statement} = parse_statement(p)
    statements = case statement do
      nil -> statements
      statement -> statements ++ [statement]
    end

    p = next_token(p)

    do_parse_program(p, statements)
  end

  defp next_token(%Parser{tokens: []} = p) do
    %{p | curr: p.peek, peek: nil}
  end
  defp next_token(%Parser{} = p) do
    [next_peek | rest] = p.tokens
    %{p | curr: p.peek, peek: next_peek, tokens: rest}
  end

  defp parse_statement(p) do
    case p.curr.type do
      :let -> parse_let_statement(p)
      :return -> parse_return_statement(p)
      _ -> parse_expression_statement(p)
    end
  end

  defp parse_let_statement(p) do
    let_token = p.curr

    with {:ok, p, ident_token} <- expect_peek(p, :ident),
         {:ok, p, _assign_token} <- expect_peek(p, :assign),
         p <- next_token(p),
         {:ok, p, value} <- parse_expression(p, @precedence_levels.lowest) do
      identifier = %Identifier{token: ident_token, value: ident_token.literal}
      statement = %LetStatement{token: let_token, name: identifier, value: value}
      p = skip_semicolon(p)
      {p, statement}
    else
      _ -> {p, nil}
    end
  end

  defp parse_return_statement(p) do
    return_token = p.curr
    p = next_token(p)
    {_, p, return_value} = parse_expression(p, @precedence_levels.lowest)
    p = skip_semicolon(p)
    statement = %ReturnStatement{token: return_token, return_value: return_value}
    {p, statement}
  end

  defp parse_expression_statement(p) do
    token = p.curr
    {_, p, expression} = parse_expression(p, @precedence_levels.lowest)
    statement = %ExpressionStatement{token: token, expression: expression}
    p = skip_semicolon(p)
    {p, statement}
  end

  defp parse_expression(p, precedence) do
    case prefix_parse_fns(p.curr.type, p) do
      {p, nil} ->
        {:error, p, nil}
      {p, expression} ->
        {p, expression} = check_infix(p, expression, precedence)
        {:ok, p, expression}
    end
  end

  defp check_infix(p, left, precedence) do
    allowed = p.peek.type != :semicolon && precedence < peek_precedence(p)

    with true <- allowed,
         infix_fn <- infix_parse_fns(p.peek.type),
         true <- infix_fn != :nil do
      p = next_token(p)
      {p, infix} = infix_fn.(p, left)
      check_infix(p, infix, precedence)
    else
      _ -> {p, left}
    end
  end

  defp prefix_parse_fns(:ident, p), do: parse_identifier(p)
  defp prefix_parse_fns(:int, p), do: parse_integer_literal(p)
  defp prefix_parse_fns(:bang, p), do: parse_prefix_expression(p)
  defp prefix_parse_fns(:minus, p), do: parse_prefix_expression(p)
  defp prefix_parse_fns(:true, p), do: parse_boolean(p)
  defp prefix_parse_fns(:false, p), do: parse_boolean(p)
  defp prefix_parse_fns(:lparen, p), do: parse_grouped_expression(p)
  defp prefix_parse_fns(:if, p), do: parse_if_expression(p)
  defp prefix_parse_fns(:function, p), do: parse_function_literal(p)
  defp prefix_parse_fns(:string, p), do: parse_string_literal(p)
  defp prefix_parse_fns(:lbracket, p), do: parse_array_literal(p)
  defp prefix_parse_fns(_, p) do
    error = "No prefix function found for #{p.curr.type}"
    p = add_error(p, error)
    {p, nil}
  end

  defp parse_identifier(p) do
    identifier = %Identifier{token: p.curr, value: p.curr.literal}
    {p, identifier}
  end

  defp parse_integer_literal(p) do
    int = Integer.parse(p.curr.literal)
    case int do
      :error ->
        error = "Could not parse #{p.curr.literal} as integer"
        p = add_error(p, error)
        {p, nil}
      {val, _} ->
        expression = %IntegerLiteral{token: p.curr, value: val}
        {p, expression}
    end
  end

  defp parse_prefix_expression(p) do
    token = p.curr
    operator = p.curr.literal

    p = next_token(p)
    {_, p, right} = parse_expression(p, @precedence_levels.prefix)
    prefix = %PrefixExpression{token: token, operator: operator, right: right}

    {p, prefix}
  end

  defp parse_boolean(p) do
    boolean = %Boolean{token: p.curr, value: p.curr.type == :true}
    {p, boolean}
  end

  defp parse_grouped_expression(p) do
    p = next_token(p)
    {_, p, expression} = parse_expression(p, @precedence_levels.lowest)

    case expect_peek(p, :rparen) do
      {:error, p, nil} -> {p, nil}
      {:ok, p, _} -> {p, expression}
    end
  end

  defp parse_if_expression(p) do
    token = p.curr

    with {:ok, p, _peek} <- expect_peek(p, :lparen),
          p = next_token(p),
          {:ok, p, condition} <- parse_expression(p, @precedence_levels.lowest),
          {:ok, p, _peek} <- expect_peek(p, :rparen),
          {:ok, p, _peek} <- expect_peek(p, :lbrace) do
          {p, consequence} = parse_block_statement(p)
          {p, alternative} = parse_if_alternative(p)
          expression = %IfExpression{token: token,
                                    condition: condition,
                                    consequence: consequence,
                                    alternative: alternative}
        {p, expression}
    else
      {:error, p, _} -> {p, nil}
    end
  end

  defp parse_if_alternative(%Parser{peek: %Token{type: :else}} = p) do
    p = next_token(p)
    case expect_peek(p, :lbrace) do
      {:error, p, _} -> {p, nil}
      {:ok, p, _} -> parse_block_statement(p)
    end
  end
  defp parse_if_alternative(p), do: {p, nil}

  defp parse_function_literal(p) do
    token = p.curr

    with {:ok, p, _peek} <- expect_peek(p, :lparen),
         {p, parameters} <- parse_function_parameters(p),
         {:ok, p, _peek} <- expect_peek(p, :lbrace) do
      {p, body} = parse_block_statement(p)
      expression = %FunctionLiteral{token: token, parameters: parameters, body: body}
      {p, expression}
    else
      {:error, p, _} -> {p, nil}
    end
  end

  defp parse_function_parameters(p, identifiers \\ []) do
    do_parse_function_parameters(p, identifiers)
  end
  defp do_parse_function_parameters(%Parser{peek: %Token{type: :rparen}} = p, [] = identifiers) do
    p = next_token(p)
    {p, identifiers}
  end
  defp do_parse_function_parameters(p, identifiers) do
    p = next_token(p)
    identifiers = identifiers ++ [%Identifier{token: p.curr, value: p.curr.literal}]

    case p.peek.type do
      :comma ->
        p = next_token(p)
        do_parse_function_parameters(p, identifiers)
      _ ->
        # TODO: no nested case please!
        case expect_peek(p, :rparen) do
          {:ok, p, _peek} -> {p, identifiers}
          {:error, p, nil} -> {p, nil}
        end
    end
  end

  defp parse_block_statement(p, statements \\ []) do
    token = p.curr
    p = next_token(p)
    do_parse_block_statement(p, token, statements)
  end
  defp do_parse_block_statement(%Parser{curr: %Token{type: :rbrace}} = p, token, statements) do
    block = %BlockStatement{token: token, statements: statements}
    {p, block}
  end
  defp do_parse_block_statement(%Parser{} = p, token, statements) do
    {p, statement} = parse_statement(p)
    statements = case statement do
      nil -> statements
      statement -> statements ++ [statement]
    end

    p = next_token(p)
    do_parse_block_statement(p, token, statements)
  end

  defp parse_string_literal(p) do
    expression = %StringLiteral{token: p.curr, value: p.curr.literal}
    {p, expression}
  end

  defp parse_array_literal(p) do
    token = p.curr
    {p, elements} = parse_expression_list(p, :rbracket)
    array = %ArrayLiteral{token: token, elements: elements}
    {p, array}
  end

  defp infix_parse_fns(:plus), do: &(parse_infix_expression(&1, &2))
  defp infix_parse_fns(:minus), do: &(parse_infix_expression(&1, &2))
  defp infix_parse_fns(:slash), do: &(parse_infix_expression(&1, &2))
  defp infix_parse_fns(:asterisk), do: &(parse_infix_expression(&1, &2))
  defp infix_parse_fns(:eq), do: &(parse_infix_expression(&1, &2))
  defp infix_parse_fns(:not_eq), do: &(parse_infix_expression(&1, &2))
  defp infix_parse_fns(:lt), do: &(parse_infix_expression(&1, &2))
  defp infix_parse_fns(:gt), do: &(parse_infix_expression(&1, &2))
  defp infix_parse_fns(:lparen), do: &(parse_call_expression(&1, &2))
  defp infix_parse_fns(:lbracket), do: &(parse_index_expression(&1, &2))
  defp infix_parse_fns(_), do: nil

  defp parse_infix_expression(p, left) do
    token = p.curr
    operator = p.curr.literal

    precedence = curr_precedence(p)
    p = next_token(p)
    {_, p, right} = parse_expression(p, precedence)
    infix = %InfixExpression{token: token, left: left, operator: operator, right: right}

    {p, infix}
  end

  defp parse_call_expression(p, function) do
    token = p.curr
    {p, arguments} = parse_expression_list(p, :rparen)
    expression = %CallExpression{token: token, function: function, arguments: arguments}
    {p, expression}
  end

  def parse_index_expression(p, left) do
    token = p.curr
    p = next_token(p)
    {_, p, index} = parse_expression(p, @precedence_levels.lowest)
    expression = %IndexExpression{token: token, left: left, index: index}

    case expect_peek(p, :rbracket) do
      {:ok, p, _peek} -> {p, expression}
      {:error, p, nil} -> {p, nil}
    end
  end

  defp parse_expression_list(p, end_token, arguments \\ []) do
    do_parse_expression_list(p, end_token, arguments)
  end
  defp do_parse_expression_list(%Parser{peek: %Token{type: end_token}} = p, end_token, [] = arguments) do
    p = next_token(p)
    {p, arguments}
  end
  defp do_parse_expression_list(p, end_token, arguments) do
    p = next_token(p)
    {_, p, argument} = parse_expression(p, @precedence_levels.lowest)
    arguments = arguments ++ [argument]

    case p.peek.type do
      :comma ->
        p = next_token(p)
        do_parse_expression_list(p, end_token, arguments)
      _ ->
        # TODO: no nested case please!
        case expect_peek(p, end_token) do
          {:ok, p, _peek} -> {p, arguments}
          {:error, p, nil} -> {p, nil}
        end
    end
  end

  defp skip_semicolon(p) do
    if p.peek.type == :semicolon, do: next_token(p), else: p
  end

  defp curr_precedence(p), do: Map.get(@precedences, p.curr.type, @precedence_levels.lowest)

  defp peek_precedence(p), do: Map.get(@precedences, p.peek.type, @precedence_levels.lowest)

  defp expect_peek(%Parser{peek: peek} = p, expected_type) do
    if peek.type == expected_type do
      p = next_token(p)
      {:ok, p, peek}
    else
      error = "Expected next token to be :#{expected_type}, got :#{peek.type} instead"
      p = add_error(p, error)
      {:error, p, nil}
    end
  end

  defp add_error(p, msg), do: %{p | errors: p.errors ++ [msg]}
end
