defmodule Grammar do
  @moduledoc """
  Documentation for Grammar.
  """

  @doc """
  Blah.

  ## Examples

      iex> Grammar.generate_all(4, :S, [{[:S], [:a, :S]}, {[:S], [:a]}], [:a], [:S])
      [[:a], [:a, :a], [:a, :a, :a], [:a, :a, :a, :a]]

  """
  def generate_all(length, start, rules, terms, nonterms) do
    generate(length, [], [], [start], rules, terms, nonterms) |> unique() |> sort()
  end

  @doc """
  Receives a list and returns the list with unique elements.

  ## Parameters
    - list: the input list

  ## Examples
      iex> Grammar.unique([2, 1, 3, 1, 4, 3, 2, 5])
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
      iex> Grammar.sort([2, 1, 3, 1, 4, 3, 2, 5])
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

  defp generate(length, prev, curr, next, rules, terms, nonterms) do
    # Parar recursão quando a palavra for maior que o tamanho máximo
    if size(next) > length do
      []
    else
      case curr do
        [] -> # curr vazio
          case next do
            [] ->
              # Verificar se prev é uma palavra com apenas terminais
              if is_made_of?(prev, terms) do
                [prev]
              else
                []
              end
            [head | tail] ->
              # Mover primeiro valor de next para curr
              generate(length, prev, [head], tail, rules, terms, nonterms)
          end
        [_ | _] -> # curr com um ou mais elementos
          if is_subrule?(curr, rules) do
            # Aplicar recursão + iteração
            case next do
              [] ->
                replace_rules(length, prev, curr, next, rules, rules, terms, nonterms) ++
                generate(length, prev ++ curr, [], [], rules, terms, nonterms)
              [head | tail] ->
                replace_rules(length, prev, curr, next, rules, rules, terms, nonterms) ++
                generate(length, prev, curr ++ [head], tail, rules, terms, nonterms) ++
                generate(length, prev ++ curr, [head], tail, rules, terms, nonterms)
            end
          else
            # Aplicar iteração
            case next do
              [] ->
                generate(length, prev ++ curr, [], [], rules, terms, nonterms)
              [head | tail] ->
                generate(length, prev ++ curr, [head], tail, rules, terms, nonterms)
            end
          end
      end
    end
  end

  defp size(list) do
    case list do
      [] -> 0
      [_ | tail] -> 1 + size(tail)
    end
  end

  defp replace_rules(length, prev, curr, next, rules, orig_rules, terms, nonterms) do
    case rules do
      [] -> []
      [{^curr, output} | tail] ->
        generate(length, [], [], prev ++ output ++ next, orig_rules, terms, nonterms) ++
        replace_rules(length, prev, curr, next, tail, orig_rules, terms, nonterms)
      [_ | tail] ->
        replace_rules(length, prev, curr, next, tail, orig_rules, terms, nonterms)
    end
  end

  defp is_made_of?(word, terms) do
    case word do
      [] -> true
      [head | tail] ->
        if contains?(head, terms) do
          is_made_of?(tail, terms)
        else
          false
        end
    end
  end

  defp contains?(elem, list) do
    case list do
      [] -> false
      [^elem | _] -> true
      [_ | tail] -> contains?(elem, tail)
    end
  end

  defp is_subrule?(word, rules) do
    case rules do
      [] -> false
      [{head, _} | tail] -> is_start?(word, head) or is_subrule?(word, tail)
    end
  end

  defp is_start?(sublist, list) do
    case sublist do
      [] -> true
      [head | subtail] ->
        case list do
          [] -> false
          [^head | tail] -> is_start?(subtail, tail)
          [_ | _] -> false
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
