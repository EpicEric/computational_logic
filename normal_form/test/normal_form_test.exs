defmodule NormalFormTest do
  use ExUnit.Case

  # Verify that we generate a CNF regular grammar correctly
  test "transform (aa)* into normal form" do
    grammar =
      NormalForm.change_to_normal_form(:S, [
        {:S, []}, {:S, [:a, :a, :S]}
      ], [:a])

    # Generated grammar should be of form:
    # [
    #   S: [],
    #   S: [:A, :B],
    #   A: [:a],
    #   B: [:A, :C],
    #   B: [:a],
    #   C: [:A, :B]
    # ]

    # -- Check general grammar form
    assert Enum.count(grammar.nonterms) == 4
    assert Enum.count(grammar.terms) == 1
    # Start is in nonterms
    assert Enum.member?(grammar.nonterms, grammar.start)
    assert Enum.count(grammar.rules) == 6
    # All rules have NTs in leftside
    assert Enum.count(Enum.filter(grammar.rules,
      &(Enum.member?(grammar.nonterms, elem(&1, 0))))) == 6
    # Rules that generate empty words
    assert Enum.count(Enum.filter(grammar.rules,
      &(elem(&1, 1) == []))) == 1
    # Rules that generate one symbol
    assert Enum.count(Enum.filter(grammar.rules,
      &(Enum.count(elem(&1, 1)) == 1))) == 2
    # Rules that generate one term
    assert Enum.count(Enum.filter(grammar.rules,
      &(Enum.count(
        Enum.filter(elem(&1, 1), fn(x) -> Enum.member?(grammar.terms, x) end)) == 1))) == 2
    # Rules that generate one nonterm
    assert Enum.count(Enum.filter(grammar.rules,
      &(Enum.count(
        Enum.filter(elem(&1, 1), fn(x) -> Enum.member?(grammar.nonterms, x) end)) == 1))) == 0
    # Rules that generate two symbols
    assert Enum.count(Enum.filter(grammar.rules,
      &(Enum.count(elem(&1, 1)) == 2))) == 3
    # Rules that generate two terms
    assert Enum.count(Enum.filter(grammar.rules,
      &(Enum.count(
        Enum.filter(elem(&1, 1), fn(x) -> Enum.member?(grammar.terms, x) end)) == 2))) == 0
    # Rules that generate term nonterm
    assert Enum.count(Enum.filter(grammar.rules,
      &(Enum.member?(grammar.terms, Enum.at(elem(&1, 1), 0)) and
      Enum.member?(grammar.nonterms, Enum.at(elem(&1, 1), 1))))) == 0
    # Rules that generate nonterm term
    assert Enum.count(Enum.filter(grammar.rules,
      &(Enum.member?(grammar.nonterms, Enum.at(elem(&1, 1), 0)) and
      Enum.member?(grammar.terms, Enum.at(elem(&1, 1), 1))))) == 0
    # Rules that generate two nonterms
    assert Enum.count(Enum.filter(grammar.rules,
      &(Enum.count(
        Enum.filter(elem(&1, 1), fn(x) -> Enum.member?(grammar.nonterms, x) end)) == 2))) == 3

    # -- Get and check S
    s = grammar.start
    # S generates empty word
    assert Enum.count(Enum.filter(grammar.rules, &(elem(&1, 1) == [] and elem(&1, 0) == s))) == 1
    # S is nonterm
    assert Enum.member?(grammar.nonterms, s)
    # S has two rules
    assert Enum.count(Enum.filter(grammar.rules, &(elem(&1, 0) == s))) == 2

    # -- Get and check A and B
    s_ab_list = Enum.filter(grammar.rules, &(elem(&1, 0) == s and elem(&1, 1) != []))
    # S has one other rule than empty rule
    assert Enum.count(s_ab_list) == 1
    # Other rule has two elements
    assert Enum.count(elem(Enum.at(s_ab_list, 0), 1)) == 2
    a = Enum.at(elem(Enum.at(s_ab_list, 0), 1), 0)
    # A is nonterm
    assert Enum.member?(grammar.nonterms, a)
    # A generates one rule
    assert Enum.count(Enum.filter(grammar.rules, &(elem(&1, 0) == a))) == 1
    b = Enum.at(elem(Enum.at(s_ab_list, 0), 1), 1)
    # B is nonterm
    assert Enum.member?(grammar.nonterms, b)
    # B generates two rules
    assert Enum.count(Enum.filter(grammar.rules, &(elem(&1, 0) == b))) == 2
    # A generates :a
    assert Enum.count(Enum.filter(grammar.rules, &(&1 == {a, [:a]}))) == 1
    # B generates :a
    assert Enum.count(Enum.filter(grammar.rules, &(&1 == {b, [:a]}))) == 1

    # -- Get and check C
    b_ac_list = Enum.filter(grammar.rules, &(elem(&1, 0) == b and elem(&1, 1) != [:a]))
    # B has one other rule than :a
    assert Enum.count(b_ac_list) == 1
    # Other rule has two elements
    assert Enum.count(elem(Enum.at(b_ac_list, 0), 1)) == 2
    # First element of other rule is A
    assert Enum.at(elem(Enum.at(b_ac_list, 0), 1), 0) == a
    c = Enum.at(elem(Enum.at(b_ac_list, 0), 1), 1)
    # C is nonterm
    assert Enum.member?(grammar.nonterms, c)
    # C generates one rule
    assert Enum.count(Enum.filter(grammar.rules, &(elem(&1, 0) == c))) == 1
    # C generates AB
    assert Enum.count(Enum.filter(grammar.rules, &(&1 == {c, [a, b]}))) == 1
  end

  # Verify that we generate a CNF context-free grammar correctly
  test "transform (a)^n(b)^n, n > 0 into normal form" do
    grammar =
      NormalForm.change_to_normal_form(:S, [
        {:S, [:a, :b]}, {:S, [:a, :S, :b]}
      ], [:a, :b])

    # Generated grammar should be of form:
    # [
    #   S: [:A, :B],
    #   S: [:A, :C],
    #   A: [:a],
    #   B: [:b],
    #   C: [:S, :B]
    # ]

    # -- Check general grammar form
    assert Enum.count(grammar.nonterms) == 4
    assert Enum.count(grammar.terms) == 2
    # Start is in nonterms
    assert Enum.member?(grammar.nonterms, grammar.start)
    assert Enum.count(grammar.rules) == 5
    # All rules have NTs in leftside
    assert Enum.count(Enum.filter(grammar.rules,
      &(Enum.member?(grammar.nonterms, elem(&1, 0))))) == 5
    # Rules that generate empty words
    assert Enum.count(Enum.filter(grammar.rules,
      &(elem(&1, 1) == []))) == 0
    # Rules that generate one symbol
    assert Enum.count(Enum.filter(grammar.rules,
      &(Enum.count(elem(&1, 1)) == 1))) == 2
    # Rules that generate one term
    assert Enum.count(Enum.filter(grammar.rules,
      &(Enum.count(
        Enum.filter(elem(&1, 1), fn(x) -> Enum.member?(grammar.terms, x) end)) == 1))) == 2
    # Rules that generate one nonterm
    assert Enum.count(Enum.filter(grammar.rules,
      &(Enum.count(
        Enum.filter(elem(&1, 1), fn(x) -> Enum.member?(grammar.nonterms, x) end)) == 1))) == 0
    # Rules that generate two symbols
    assert Enum.count(Enum.filter(grammar.rules,
      &(Enum.count(elem(&1, 1)) == 2))) == 3
    # Rules that generate two terms
    assert Enum.count(Enum.filter(grammar.rules,
      &(Enum.count(
        Enum.filter(elem(&1, 1), fn(x) -> Enum.member?(grammar.terms, x) end)) == 2))) == 0
    # Rules that generate term nonterm
    assert Enum.count(Enum.filter(grammar.rules,
      &(Enum.member?(grammar.terms, Enum.at(elem(&1, 1), 0)) and
      Enum.member?(grammar.nonterms, Enum.at(elem(&1, 1), 1))))) == 0
    # Rules that generate nonterm term
    assert Enum.count(Enum.filter(grammar.rules,
      &(Enum.member?(grammar.nonterms, Enum.at(elem(&1, 1), 0)) and
      Enum.member?(grammar.terms, Enum.at(elem(&1, 1), 1))))) == 0
    # Rules that generate two nonterms
    assert Enum.count(Enum.filter(grammar.rules,
      &(Enum.count(
        Enum.filter(elem(&1, 1), fn(x) -> Enum.member?(grammar.nonterms, x) end)) == 2))) == 3
    
    # -- Get and check S
    s = grammar.start
    # S is nonterm
    assert Enum.member?(grammar.nonterms, s)
    # S has two rules
    assert Enum.count(Enum.filter(grammar.rules, &(elem(&1, 0) == s))) == 2

    # -- Get and check C and B
    c_sb_list = Enum.filter(grammar.rules, &(Enum.at(elem(&1, 1), 0) == s))
    # S is generated by one rule
    assert Enum.count(c_sb_list) == 1
    # This rule generates two elements
    assert Enum.count(elem(Enum.at(c_sb_list, 0), 1)) == 2
    c = elem(Enum.at(c_sb_list, 0), 0)
    # C is nonterm
    assert Enum.member?(grammar.nonterms, c)
    # C generates one rule
    assert Enum.count(Enum.filter(grammar.rules, &(elem(&1, 0) == c))) == 1
    b = Enum.at(elem(Enum.at(c_sb_list, 0), 1), 1)
    # B is nonterm
    assert Enum.member?(grammar.nonterms, b)
    # B generates one rule
    assert Enum.count(Enum.filter(grammar.rules, &(elem(&1, 0) == b))) == 1
    # B generates :b
    assert Enum.count(Enum.filter(grammar.rules, &(elem(&1, 0) == b and elem(&1, 1) == [:b]))) == 1

    # -- Get and check A
    s_ac_list = Enum.filter(grammar.rules, &(elem(&1, 0) == s and Enum.at(elem(&1, 1), 1) == c))
    # There's only one of this rule
    assert Enum.count(s_ac_list) == 1
    # This rule generates two elements
    assert Enum.count(elem(Enum.at(s_ac_list, 0), 1)) == 2
    a = Enum.at(elem(Enum.at(s_ac_list, 0), 1), 0)
    # A is nonterm
    assert Enum.member?(grammar.nonterms, a)
    # A generates one rule
    assert Enum.count(Enum.filter(grammar.rules, &(elem(&1, 0) == a))) == 1
    # A generates :a
    assert Enum.count(Enum.filter(grammar.rules, &(elem(&1, 0) == a and elem(&1, 1) == [:a]))) == 1
    # Two rules generate A as first element
    assert Enum.count(Enum.filter(grammar.rules, &(Enum.at(elem(&1, 1), 0) == a))) == 2
    # No rules generate A as second element
    assert Enum.count(Enum.filter(grammar.rules, &(Enum.at(elem(&1, 1), 1) == a))) == 0
  end

  # Verify that we can identify words for a CNF regular grammar
  test "identify words for a(ab)*" do
    grammar = %NormalForm{
      start: :S0,
      rules: [
        {:S0, [:A, :C]},
        {:S0, [:a]},
        {:A, [:a]},
        {:B, [:b]},
        {:C, [:A, :B]},
        {:C, [:A, :D]},
        {:D, [:B, :C]}],
      terms: [:a, :b],
      nonterms: [:S0, :A, :B, :C, :D]
    }

    assert NormalForm.normal_form_grammar_generates_word?(grammar, [:a])
    assert NormalForm.normal_form_grammar_generates_word?(grammar, [:a, :a, :b])
    assert NormalForm.normal_form_grammar_generates_word?(grammar, [:a, :a, :b, :a, :b])
    assert NormalForm.normal_form_grammar_generates_word?(grammar, [:a, :a, :b, :a, :b, :a, :b])

    assert not NormalForm.normal_form_grammar_generates_word?(grammar, [])
    assert not NormalForm.normal_form_grammar_generates_word?(grammar, [:b])
    assert not NormalForm.normal_form_grammar_generates_word?(grammar, [:c])
    assert not NormalForm.normal_form_grammar_generates_word?(grammar, [:a, :b])
    assert not NormalForm.normal_form_grammar_generates_word?(grammar, [:a, :c])
    assert not NormalForm.normal_form_grammar_generates_word?(grammar, [:a, :a])
    assert not NormalForm.normal_form_grammar_generates_word?(grammar, [:a, :a, :b, :c])
    assert not NormalForm.normal_form_grammar_generates_word?(grammar, [:a, :a, :b, :a])
  end

  # Verify that we can identify words for a CNF context-free grammar
  test "identify words for balanced parentheses" do
    grammar = %NormalForm{
      start: :S0,
      rules: [
        {:S0, []},
        {:O, ["("]},
        {:C, [")"]},
        {:S0, [:S, :S]},
        {:S0, [:O, :C]},
        {:S0, [:O, :S1]},
        {:S, [:S, :S]},
        {:S, [:O, :C]},
        {:S, [:O, :S1]},
        {:S1, [:S, :C]}],
      terms: ["(", ")"],
      nonterms: [:S0, :O, :C, :S, :S1]}
    
    assert NormalForm.normal_form_grammar_generates_word?(grammar, [])
    assert NormalForm.normal_form_grammar_generates_word?(grammar, ["(", ")"])
    assert NormalForm.normal_form_grammar_generates_word?(grammar, ["(", "(", ")", ")"])
    assert NormalForm.normal_form_grammar_generates_word?(grammar, ["(", ")", "(", ")"])
    assert NormalForm.normal_form_grammar_generates_word?(grammar, ["(", "(", "(", ")", ")", ")"])
    assert NormalForm.normal_form_grammar_generates_word?(grammar, ["(", "(", ")", "(", "(", ")", ")", ")"])

    assert not NormalForm.normal_form_grammar_generates_word?(grammar, ["a"])
    assert not NormalForm.normal_form_grammar_generates_word?(grammar, ["("])
    assert not NormalForm.normal_form_grammar_generates_word?(grammar, [")"])
    assert not NormalForm.normal_form_grammar_generates_word?(grammar, [")", "("])
    assert not NormalForm.normal_form_grammar_generates_word?(grammar, ["(", "("])
    assert not NormalForm.normal_form_grammar_generates_word?(grammar, [")", ")"])
    assert not NormalForm.normal_form_grammar_generates_word?(grammar, ["(", ")", ")"])
    assert not NormalForm.normal_form_grammar_generates_word?(grammar, ["(", "", ")"])
    assert not NormalForm.normal_form_grammar_generates_word?(grammar, ["(", "(", ")", "(", "(", ")", ")"])
  end
end
