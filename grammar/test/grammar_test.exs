defmodule GrammarTest do
  use ExUnit.Case
  doctest Grammar

  test "generate regular grammar" do
    # e(e|f)*(f|g)*
    assert Grammar.generate_all(3, :S, [
      {[:S], [:e, :E]},
      {[:S], [:e]},
      {[:E], [:e, :E]},
      {[:E], [:f, :E]},
      {[:E], [:g, :F]},
      {[:E], [:e]},
      {[:E], [:f]},
      {[:E], [:g]},
      {[:F], [:f, :F]},
      {[:F], [:g, :F]},
      {[:F], [:f]},
      {[:F], [:g]}
    ], [:e, :f, :g], [:S, :E, :F]) ==
    [
      [:e],
      [:e, :e],
      [:e, :e, :e],
      [:e, :e, :f],
      [:e, :e, :g],
      [:e, :f],
      [:e, :f, :e],
      [:e, :f, :f],
      [:e, :f, :g],
      [:e, :g],
      [:e, :g, :f],
      [:e, :g, :g]
    ]
  end

  test "generate regular grammar with empty element" do
    # (a)*
    assert Grammar.generate_all(10, :S, [
      {[:S], []},
      {[:S], [:A]},
      {[:A], [:A, :a]},
      {[:A], [:a]}
    ], [:a], [:S, :A]) ==
    [
      [],
      [:a],
      [:a, :a],
      [:a, :a, :a],
      [:a, :a, :a, :a],
      [:a, :a, :a, :a, :a,],
      [:a, :a, :a, :a, :a, :a],
      [:a, :a, :a, :a, :a, :a, :a],
      [:a, :a, :a, :a, :a, :a, :a, :a],
      [:a, :a, :a, :a, :a, :a, :a, :a, :a],
      [:a, :a, :a, :a, :a, :a, :a, :a, :a, :a]
    ]
  end

  test "generate context-free grammar" do
    # (c)^N(d)^N, N >= 1
    assert Grammar.generate_all(9, :S, [
      {[:S], [:c, :S, :D]},
      {[:S], [:c, :d]},
      {[:D], [:d]}
    ], [:c, :d], [:S, :D]) ==
    [
      [:c, :c, :c, :c, :d, :d, :d, :d],
      [:c, :c, :c, :d, :d, :d],
      [:c, :c, :d, :d],
      [:c, :d]
    ]
  end

  test "generate context-free grammar with empty element" do
    # Balanced parentheses
    assert Grammar.generate_all(6, :S, [
      {[:S], []},
      {[:S], [:P]},
      {[:P], [:P, :P]},
      {[:P], ["(", :P, ")"]},
      {[:P], ["(", ")"]}
    ], ["(", ")"], [:S, :P]) ==
    [
      [],
      ["(", "(", "(", ")", ")", ")"],
      ["(", "(", ")", "(", ")", ")"],
      ["(", "(", ")", ")"],
      ["(", "(", ")", ")", "(", ")"],
      ["(", ")"],
      ["(", ")", "(", "(", ")", ")"],
      ["(", ")", "(", ")"],
      ["(", ")", "(", ")", "(", ")"]
    ]
  end

  test "generate context-sensitive grammar" do
    # (1)^N(2)^N(3)^N, N >= 1
    assert Grammar.generate_all(9, :S, [
      {[:S], [1, :II, :III]},
      {[:S], [1, :S, :II, :III]},
      {[:III, :II], [:II, :III]},
      {[1, :II], [1, 2]},
      {[2, :II], [2, 2]},
      {[2, :III], [2, 3]},
      {[3, :III], [3, 3]}
    ], [1, 2, 3], [:S, :II, :III]) ==
    [
      [1, 1, 1, 2, 2, 2, 3, 3, 3],
      [1, 1, 2, 2, 3, 3],
      [1, 2, 3]
    ]
  end

  test "generate context-sensitive grammar with empty element" do
    # #x == #y
    assert Grammar.generate_all(4, :S, [
      {[:S], []},
      {[:S], [:Z]},
      {[:Z], [:X, :Y]},
      {[:Z], [:X, :Y, :Z]},
      {[:X, :Y], [:Y, :X]},
      {[:Y, :X], [:X, :Y]},
      {[:X], [:x]},
      {[:Y], [:y]}
    ], [:x, :y], [:S, :X, :Y, :Z]) ==
    [
      [],
      [:x, :x, :y, :y],
      [:x, :y],
      [:x, :y, :x, :y],
      [:x, :y, :y, :x],
      [:y, :x],
      [:y, :x, :x, :y],
      [:y, :x, :y, :x],
      [:y, :y, :x, :x]
    ]
  end
end
