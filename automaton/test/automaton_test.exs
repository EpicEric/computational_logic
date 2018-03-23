defmodule AutomatonTest do
  use ExUnit.Case
  doctest Automaton

  test "dfa word generation" do
    automaton = %Automaton{
      transitions: [
        [:q0, :a, :q1],
        [:q0, :b, :qR],
        [:q0, :c, :qR],
        [:q1, :a, :q1],
        [:q1, :b, :q2],
        [:q1, :c, :qR],
        [:q2, :a, :qR],
        [:q2, :b, :q2],
        [:q2, :c, :q3],
        [:q3, :a, :q4],
        [:q3, :b, :qR],
        [:q3, :c, :q3],
        [:q4, :a, :q4],
        [:q4, :b, :q2],
        [:q4, :c, :qR],
        [:qR, :a, :qR],
        [:qR, :b, :qR],
        [:qR, :c, :qR]
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
    assert not Automaton.dfa_generates_word?(automaton, [:a, :a, :b, :b])
    assert not Automaton.dfa_generates_word?(automaton, [:a, :c])
    assert not Automaton.dfa_generates_word?(automaton, [:a, :b, :b, :c, :b])
    assert not Automaton.dfa_generates_word?(automaton, [:a, :b, :c, :a, :a])
    assert not Automaton.dfa_generates_word?(automaton, [:a, :b, :b, :c, :c, :c, :a, :b])
    assert not Automaton.dfa_generates_word?(automaton, [:a, :b, :c, :a, :b, :c, :a])
  end
end
