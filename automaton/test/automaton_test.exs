defmodule AutomatonTest do
  use ExUnit.Case
  doctest Automaton

  test "dfa word generation" do
    # a*|(a*b*c*)*
    automaton = %Automaton{
      transitions: [
        {:q0, :a, :q1},
        {:q0, :b, :qR},
        {:q0, :c, :qR},
        {:q1, :a, :q1},
        {:q1, :b, :q2},
        {:q1, :c, :qR},
        {:q2, :a, :qR},
        {:q2, :b, :q2},
        {:q2, :c, :q3},
        {:q3, :a, :q4},
        {:q3, :b, :qR},
        {:q3, :c, :q3},
        {:q4, :a, :q4},
        {:q4, :b, :q2},
        {:q4, :c, :qR},
        {:qR, :a, :qR},
        {:qR, :b, :qR},
        {:qR, :c, :qR}
      ],
      initial_state: :q0,
      accept_states: [:q1, :q3]
    }
    assert Automaton.dfa_generates_word?(automaton, [:a])
    assert Automaton.dfa_generates_word?(automaton, [:a, :a])
    assert Automaton.dfa_generates_word?(automaton, [:a, :a, :a])
    assert Automaton.dfa_generates_word?(automaton, [:a, :b, :c])
    assert Automaton.dfa_generates_word?(automaton, [:a, :a, :a, :b, :c, :c])
    assert Automaton.dfa_generates_word?(automaton, [:a, :b, :b, :b, :b, :b, :c, :c, :c])
    assert Automaton.dfa_generates_word?(automaton, [:a, :b, :b, :c, :a, :a, :a, :b, :c, :c])
    assert Automaton.dfa_generates_word?(automaton, [:a, :b, :c, :a, :b, :c, :a, :b, :c])
    assert not Automaton.dfa_generates_word?(automaton, [])
    assert not Automaton.dfa_generates_word?(automaton, [:b])
    assert not Automaton.dfa_generates_word?(automaton, [:c])
    assert not Automaton.dfa_generates_word?(automaton, [:b, :a])
    assert not Automaton.dfa_generates_word?(automaton, [:b, :c])
    assert not Automaton.dfa_generates_word?(automaton, [:c, :a])
    assert not Automaton.dfa_generates_word?(automaton, [:c, :b])
    assert not Automaton.dfa_generates_word?(automaton, [:a, :a, :b, :b])
    assert not Automaton.dfa_generates_word?(automaton, [:a, :c])
    assert not Automaton.dfa_generates_word?(automaton, [:a, :b, :b, :c, :b])
    assert not Automaton.dfa_generates_word?(automaton, [:a, :b, :c, :a, :a])
    assert not Automaton.dfa_generates_word?(automaton, [:a, :b, :b, :c, :c, :c, :a, :b])
    assert not Automaton.dfa_generates_word?(automaton, [:a, :b, :c, :a, :b, :c, :a])
  end

  test "nfa word generation" do
    # 0*|(01)*
    automaton = %Automaton{
      transitions: [
        {:q0, nil, :q1},
        {:q0, nil, :q2},
        {:q1, 0, :q1},
        {:q2, 0, :q3},
        {:q3, 1, :q4},
        {:q4, nil, :q2}
      ],
      initial_state: :q0,
      accept_states: [:q1, :q4]
    }
    # assert Automaton.nfa_generates_word?(automaton, [])
    assert Automaton.nfa_generates_word?(automaton, [0])
    assert Automaton.nfa_generates_word?(automaton, [0, 0, 0])
    assert Automaton.nfa_generates_word?(automaton, [0, 0, 0, 0, 0])
    assert Automaton.nfa_generates_word?(automaton, [0, 1])
    assert Automaton.nfa_generates_word?(automaton, [0, 1, 0, 1])
    assert not Automaton.nfa_generates_word?(automaton, [1])
    assert not Automaton.nfa_generates_word?(automaton, [1, 0])
    assert not Automaton.nfa_generates_word?(automaton, [1, 1])
    assert not Automaton.nfa_generates_word?(automaton, [0, 0, 1])
    assert not Automaton.nfa_generates_word?(automaton, [0, 1, 1])
    assert not Automaton.nfa_generates_word?(automaton, [0, 1, 0, 0])
  end

  test "property: nfa generates the same words as dfa" do
    # a(a|b)*(c(b|c)*)?
    dfa_automaton = %Automaton{
      transitions: [
        {:a, :a, :b},
        {:a, :b, :d},
        {:a, :c, :d},
        {:b, :a, :b},
        {:b, :b, :b},
        {:b, :c, :c},
        {:c, :a, :d},
        {:c, :b, :c},
        {:c, :c, :c},
        {:d, :a, :d},
        {:d, :b, :d},
        {:d, :c, :d}
      ],
      initial_state: :a,
      accept_states: [:b, :c]
    }
    nfa_automaton = %Automaton{
      transitions: [
        {1, :a, 2},
        {1, :a, 3},
        {2, :a, 2},
        {2, :b, 2},
        {2, :c, 3},
        {3, :b, 3},
        {3, :c, 3}
      ],
      initial_state: 1,
      accept_states: [2, 3]
    }
    Enum.map(
      Enum.reduce(1..100, [],
        fn(_, acc) -> [
          Enum.take(Stream.repeatedly(fn -> Enum.random([:a, :b, :c]) end), Enum.random(0..5))
        | acc] end),
      fn(word) -> assert(
        Automaton.dfa_generates_word?(dfa_automaton, word) ==
        Automaton.nfa_generates_word?(nfa_automaton, word)) end)
  end
end
