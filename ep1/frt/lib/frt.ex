defmodule FRT do
  @moduledoc """
  A reflexive transitive closure module.
  """

  @doc """
  Receives a binary relation R and the set A such that R ⊆ A × A,
  and returns the reflexive transitive closure of R on A.
  The order of elements in the closure has no relevance.

  ## Examples

      iex> FRT.of([{:a, :b}, {:b, :c}], [:a, :b, :c])
      [a: :a, a: :b, a: :c, b: :b, b: :c, c: :c]

  """
  def of(relation, set) do
    case set do
      [] -> []
      [head | tail] ->
        Enum.uniq(
          transitive_reflexive_for_value(relation, relation, head, head) ++
          of(relation, tail))
    end
  end

  defp transitive_reflexive_for_value(relation, current_relation, origin, current_element) do
    case current_relation do
      [] -> [{origin, current_element}]
      [head | tail] -> case head do
        {^current_element, value} ->
          case value do
            ^origin ->
              transitive_reflexive_for_value(relation, tail, origin, current_element)
            ^current_element ->
              transitive_reflexive_for_value(relation, tail, origin, current_element)
            _ ->
              transitive_reflexive_for_value(relation, tail, origin, current_element) ++
              transitive_reflexive_for_value(relation, relation, origin, value)
          end
        _ ->
          transitive_reflexive_for_value(relation, tail, origin, current_element)
      end
    end
  end
end
