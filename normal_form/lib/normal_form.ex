defmodule NormalForm do
  @moduledoc """
  Documentation for NormalForm.

  A Normal Form grammar struct requires four parameters:
    - start: the start non-terminal for the grammar
    - rules: the list of tuples representing grammar rules
    - terms: the list of atoms representing terminals of the grammar
    - nonterms: the list of atoms representing non-terminals of the grammar
  """
  @enforce_keys [:start, :rules, :terms, :nonterms]
  defstruct [:start, :rules, :terms, :nonterms]

  @doc """
  Hello world.

  ## Examples

      iex> NormalForm.hello
      :world

  """
  def hello do
    :world
  end

  @doc """
  Given a context-free grammar, convert it to a grammar in Chomsky normal form.

  ## Parameters
    - start: the start non-terminal for the grammar
    - rules: the list of tuples representing grammar rules
    - terms: the list of atoms representing terminals of the grammar

  """
  def change_to_normal_form(start, rules, terms) do
    # --- 1st step: Eliminate the start symbol from right-hand sides
    new_start = create_new_atom(nil, start, "_0")
    start_rules = get_start(rules, new_start, start)

    # --- 2nd step: Eliminate rules with nonsolitary terminals
    term_rules = get_term(start_rules, terms)

    # --- 3rd step: Eliminate right-hand sides with more than 2 nonterminals
    bin_rules = get_bin(term_rules)

    # --- 4th step: Eliminate empty-generating rules
    del_rules = get_del(bin_rules, new_start)

    # --- 5th step: Eliminate unit rules
    unit_rules = get_unit(del_rules, terms, new_start)

    %NormalForm{
      start: new_start,
      rules: unit_rules,
      terms: terms,
      nonterms: Enum.uniq(Enum.map(unit_rules, fn(x) -> elem(x, 0) end))}
  end

  defp create_new_atom(prefix, element, suffix) do
    cond do
      is_atom(element) -> :"#{prefix}#{Atom.to_string(element)}#{suffix}"
      true -> :"#{prefix}#{element}#{suffix}"
    end
  end

  defp get_start(rules, new_start, start) do
    [{new_start, [start]} | rules]
  end

  defp get_term(rules, terms) do
    # Iterate over every rule
    Enum.uniq(Enum.reduce(rules, [], fn(rule, rule_acc) ->
      # Iterate over right-hand side elements
      rule_acc ++ Enum.reduce(elem(rule, 1), [rule], fn(element, added_rules) ->
        # Create new nonterms if a rule contains nonsolitary terminals
        if Enum.count(elem(rule, 1)) > 1 and Enum.member?(terms, element) do
          new_nonterm = create_new_atom("NT_", element, nil)
          # Get current rule from list of rules to be added
          [current_rule | tail] = added_rules
          # Replace term with new nonterm in current rule
          [{elem(current_rule, 0), Enum.map(elem(current_rule, 1),
              fn(x) -> if x == element do new_nonterm else x end end)},
            # Add new rule generating term from new nonterm
            {new_nonterm, [element]}] ++ tail
        else
          added_rules
        end
      end) end))
  end

  defp get_bin(rules) do
    Enum.reduce(rules, [], fn(rule, rule_acc) ->
      # Iterate over right-hand side elements
      rule_acc ++ get_bin_for_rule(
        elem(rule, 0), elem(rule, 1), Enum.count(rule_acc)) end)
  end

  defp get_bin_for_rule(leftside, rightside, iter, suffix \\ 0) do
    # If this is a new nonterm, add a suffix to the leftside of new rules
    new_leftside =
      if suffix > 0 do
        create_new_atom(nil, leftside, "_#{iter}_#{suffix}")
      else
        leftside
      end
    # Only add new rules if rightside has more than two nonterms
    case rightside do
      [] -> [{new_leftside, rightside}]
      [_] -> [{new_leftside, rightside}]
      [_, _] -> [{new_leftside, rightside}]
      [head | tail] -> 
        # Create unique suffix for the new rule
        new_suffix =
          "_#{iter}_#{suffix + 1}"
        # Recurse over rightside
        [{new_leftside, [head, create_new_atom(nil, leftside, new_suffix)]}]
          ++ get_bin_for_rule(leftside, tail, iter, suffix + 1)
    end
  end

  defp get_del(rules, start) do
    # Find a rule, other than the start nonterm, that generates an empty word
    if (index = Enum.find_index(rules, fn(x) ->
        elem(x, 0) != start and elem(x, 1) == [] end)) != nil do
      # Remove the selected rule
      empty_rule = Enum.at(rules, index)
      rules_no_empty = List.delete_at(rules, index)
      # For each rule, attempt to replace the empty-generating nonterm whenever possible
      new_rules = Enum.reduce(rules_no_empty, [], fn(rule, rule_acc) ->
        rule_acc ++ get_del_for_rule(elem(empty_rule, 0), rule) end)
      # Recurse to find more rules
      get_del(new_rules, start)
    else
      # No more empty-generating rules; End recursion
      rules
    end
  end

  defp get_del_for_rule(null_nonterm, rule) do
    # Iterate over every element in the current rule to generate all possible paths
    Enum.reduce(elem(rule, 1), [{elem(rule, 0), []}], fn(element, del_rules) ->
      Enum.uniq(
        # Add the next element to every possible rule
        Enum.map(del_rules, fn(r) -> {elem(r, 0), elem(r, 1) ++ [element]} end)
      # If the current element is the empty-generating nonterm, also add paths
      # where the element is removed from rule generation
      ++ if element == null_nonterm do del_rules else [] end)
    end)
  end

  defp get_unit(rules, terms, start) do
    # Find a rule that generates a single nonterm
    if (index = Enum.find_index(rules, fn(x) ->
        Enum.count(elem(x, 1)) == 1
        and not Enum.member?(terms, Enum.at(elem(x, 1), 0)) end)) != nil do
      # Remove the selected rule
      single_nt_rule = Enum.at(rules, index)
      rules_no_single_nt = List.delete_at(rules, index)
      # For each rule, attempt to replace the single-generating nonterm whenever possible
      new_rules = Enum.reduce(rules_no_single_nt, [], fn(rule, rule_acc) ->
        # Add new rules with the single nonterm on the left-hand side
        rule_acc ++ if Enum.at(elem(single_nt_rule, 1), 0) == elem(rule, 0) do
          [rule, {elem(single_nt_rule, 0), elem(rule, 1)}]
        else
          [rule]
        end end)
      # Recurse to find more rules
      get_unit(new_rules, terms, start)
    else
      # No more single nonterm-generating rules;
      # Remove unreachable nonterm rules and end recursion
      remove_unreachable_nonterms(
        Enum.uniq(rules),
        Enum.uniq(Enum.map(rules, fn(x) -> elem(x, 0) end)),
        start)
    end
  end

  defp remove_unreachable_nonterms(rules, nonterms, start) do
    # Find a nonterm that cannot be reached
    if (index = Enum.find_index(nonterms, fn(nt) ->
        nt != start and not Enum.any?(rules, fn(r) -> 
          Enum.member?(elem(r, 1), nt) end) end)) != nil do
      # Remove the selected nonterm
      unreachable_nt = Enum.at(nonterms, index)
      nonterms_no_unreachable = List.delete_at(nonterms, index)
      # Remove all rules with the unreachable nonterm at the left-hand side
      new_rules = Enum.filter(rules, fn(x) -> elem(x, 0) != unreachable_nt end)
      # Recurse to find more unreachable nonterms
      remove_unreachable_nonterms(new_rules, nonterms_no_unreachable, start)
    else
      # No more unreachable nonterms; End recursion
      rules
    end
  end
end
