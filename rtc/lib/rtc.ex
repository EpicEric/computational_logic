defmodule RTC do
  @moduledoc """
  A reflexive transitive closure module.
  """

  @doc """
  Receives a binary relation R and the set A such that R ⊆ A × A,
  and returns the reflexive transitive closure of R on A.
  The elements in the returned closure have no order.

  ## Parameters
    - relation: the binary relation R as a list of tuples of atoms
    - set: the set A as a list of atoms

  ## Examples
      iex> RTC.of([{:a, :b}, {:b, :c}], [:a, :b, :c])
      [a: :a, a: :b, a: :c, b: :b, b: :c, c: :c]

  """
  def of(relation, set) do
    unique(rtc(relation, set))
  end

  defp unique(list) do
    case list do
      [] -> []
      [head | tail] -> [head] ++ unique(remove_duplicates_of(head, tail))
    end
  end

  defp remove_duplicates_of(elem, list) do
    case list do
      [] -> []
      [^elem | tail] -> remove_duplicates_of(elem, tail)
      [head | tail] -> [head] ++ remove_duplicates_of(elem, tail)
    end
  end

  defp rtc(relation, set) do
    case set do
      [] -> []
      [head | tail] ->
        reflexive_transitive_for_value(relation, relation, head, head) ++
        rtc(relation, tail)
    end
  end

  defp reflexive_transitive_for_value(relation, current_relation, origin, current_element) do
    case current_relation do
      [] -> [{origin, current_element}]
      [head | tail] -> case head do
        {^current_element, value} ->
          case value do
            ^origin ->
              reflexive_transitive_for_value(relation, tail, origin, current_element)
            ^current_element ->
              reflexive_transitive_for_value(relation, tail, origin, current_element)
            _ ->
              reflexive_transitive_for_value(relation, tail, origin, current_element) ++
              reflexive_transitive_for_value(relation, relation, origin, value)
          end
        _ ->
          reflexive_transitive_for_value(relation, tail, origin, current_element)
      end
    end
  end
end
