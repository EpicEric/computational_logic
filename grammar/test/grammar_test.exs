defmodule GrammarTest do
  use ExUnit.Case
  doctest Grammar

  test "generate regular grammar" do
    assert Grammar.generate_all(6, :S, [
      {[:S], [:a, :S]},
      {[:S], [:a]}
    ], [:a], [:S]) == [[:a], [:a, :a], [:a, :a, :a], [:a, :a, :a, :a], [:a, :a, :a, :a, :a,], [:a, :a, :a, :a, :a, :a]]
  end

  test "generate context-free grammar" do
    assert Grammar.generate_all(6, :S, [
      {[:S], [:a, :S, :B]},
      {[:S], [:a, :b]},
      {[:B], [:b]}
    ], [:a, :b], [:S, :B]) == [[:a, :a, :a, :b, :b, :b], [:a, :a, :b, :b], [:a, :b]]
  end

  test "generate context-sensitive grammar" do
    assert Grammar.generate_all(6, :S, [
      {[:S], [:a, :B, :C]},
      {[:S], [:a, :S, :B, :C]},
      {[:C, :B], [:B, :C]},
      {[:a, :B], [:a, :b]},
      {[:b, :B], [:b, :b]},
      {[:b, :C], [:b, :c]},
      {[:c, :C], [:c, :c]}
    ], [:a, :b, :c], [:S, :A, :B, :C]) == [[:a, :a, :b, :b, :c, :c], [:a, :b, :c]]
  end
end
