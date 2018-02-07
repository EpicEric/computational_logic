defmodule RTC do
  @moduledoc """
  A reflexive transitive closure module.
  """

  @doc """
  Receives a binary relation R and the set A such that R ⊆ A × A,
  and returns the reflexive transitive closure of R on A.
  The elements in the returned closure are ordered.

  ## Parameters
    - relation: the binary relation R as a list of tuples of atoms
    - set: the set A as a list of atoms

  ## Examples
      iex> RTC.of([{:a, :b}, {:b, :c}], [:a, :b, :c])
      [a: :a, a: :b, a: :c, b: :b, b: :c, c: :c]

  """
  def of(relation, set) do
    rtc(relation, set) |> unique() |> sort()
  end

  @doc """
  Receives a list and returns the list with unique elements.

  ## Parameters
    - list: the input list

  ## Examples
      iex> RTC.unique([2, 1, 3, 1, 4, 3, 2, 5])
      [2, 1, 3, 4, 5]

  """
  def unique(list) do
    case list do
      [] -> []
      [head | tail] -> [head] ++ unique(remove_duplicates_of(head, tail))
    end
  end

  @doc """
  Receives a list and returns the sorted list through bubblesort.

  ## Parameters
    - list: the input list

  ## Examples
      iex> RTC.sort([2, 1, 3, 1, 4, 3, 2, 5])
      [1, 1, 2, 2, 3, 3, 4, 5]

  """
  def sort(list) do
    case list do
      [] -> []
      [head | tail] ->
        {smallest, new_tail} = get_smallest_element(head, tail)
        [smallest] ++ sort(new_tail)
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

  defp remove_duplicates_of(elem, list) do
    case list do
      [] -> []
      [^elem | tail] -> remove_duplicates_of(elem, tail)
      [head | tail] -> [head] ++ remove_duplicates_of(elem, tail)
    end
  end

  defp get_smallest_element(elem, list) do
    case list do
      [] -> {elem, list}
      [head | tail] ->
        if head < elem do
          {smallest, new_tail} = get_smallest_element(head, tail)
          {smallest, [elem] ++ new_tail}
        else
          {smallest, new_tail} = get_smallest_element(elem, tail)
          {smallest, [head] ++ new_tail}
        end
    end
  end
end
