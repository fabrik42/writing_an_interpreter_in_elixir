defmodule Monkey.Object.HashKeyTest do
  use ExUnit.Case

  alias Monkey.Object.Boolean
  alias Monkey.Object.Hash
  alias Monkey.Object.Integer
  alias Monkey.Object.String

  test "string hash keys" do
    hello1 = %String{value: "Hello World"}
    hello2 = %String{value: "Hello World"}

    diff1 = %String{value: "My name is johnny"}
    diff2 = %String{value: "My name is johnny"}

    assert Hash.Hashable.hash(hello1) == Hash.Hashable.hash(hello2)
    assert Hash.Hashable.hash(diff1) == Hash.Hashable.hash(diff2)
    assert Hash.Hashable.hash(hello1) != Hash.Hashable.hash(diff1)
  end

  test "boolean hash keys" do
    true1 = %Boolean{value: true}
    true2 = %Boolean{value: true}
    false1 = %Boolean{value: false}
    false2 = %Boolean{value: false}

    assert Hash.Hashable.hash(true1) == Hash.Hashable.hash(true2)
    assert Hash.Hashable.hash(false1) == Hash.Hashable.hash(false2)
    assert Hash.Hashable.hash(true1) != Hash.Hashable.hash(false1)
  end

  test "integer hash keys" do
    one1 = %Integer{value: 1}
    one2 = %Integer{value: 1}
    two1 = %Integer{value: 2}
    two2 = %Integer{value: 2}

    assert Hash.Hashable.hash(one1) == Hash.Hashable.hash(one2)
    assert Hash.Hashable.hash(two1) == Hash.Hashable.hash(two2)
    assert Hash.Hashable.hash(one1) != Hash.Hashable.hash(two1)
  end
end
