defmodule Grammar do
  @moduledoc """
  Documentation for Grammar.
  """

  @doc """
  Given a context-sensitive grammar and a list, returns whether that list
  belongs to the language generated by the grammar.

  ## Parameters
    - list: the list representing a word to be verified against the language
    - start: the start non-terminal for the grammar
    - rules: the list of tuples representing grammar rules
    - terms: the list of terminals of the grammar
    - nonterms: the list of non-terminals of the grammar

  ## Examples

      iex> Grammar.generates_word?([:a, :a, :b], :S, [{[:S], [:a, :S, :b]}, {[:S], [:a, :b]}], [:a, :b], [:S])
      false
      iex> Grammar.generates_word?([:a, :a, :b, :b], :S, [{[:S], [:a, :S, :b]}, {[:S], [:a, :b]}], [:a, :b], [:S])
      true

  """
  def generates_word?(list, start, rules, terms, nonterms) do
    Enum.member?(generate_all(Enum.count(list), start, rules, terms, nonterms), list)
  end

  @doc """
  Given a context-sensitive grammar and a length, generates all possible words
  of the language with size less than or equal to the provided length.
  The generated list will be ordered and will have unique elements.

  ## Parameters
    - length: the max length as an integer of generated strings
    - start: the start non-terminal for the grammar
    - rules: the list of tuples representing grammar rules
    - terms: the list of terminals of the grammar
    - nonterms: the list of non-terminals of the grammar

  ## Examples

      iex> Grammar.generate_all(4, :S, [{[:S], [:a, :S]}, {[:S], [:a]}], [:a], [:S])
      [[:a], [:a, :a], [:a, :a, :a], [:a, :a, :a, :a]]

  """
  def generate_all(length, start, rules, terms, nonterms) do
    generate(length, [], [start], rules, rules, [], terms, nonterms) |> Enum.uniq() |> Enum.sort()
  end

  defp generate(length, prev, next, rules, orig_rules, path, terms, nonterms) do
    # Parar recursão quando a palavra for maior que o tamanho máximo
    if Enum.count(next) > length do
      []
    else
      case rules do
        [] ->
          case next do
            [] ->
              # Verificar se prev é uma palavra com apenas terminais
              if Enum.all?(prev, fn(x) -> Enum.member?(terms, x) end) do
                [prev]
              else
                []
              end
            [head | tail] ->
              # Mover primeiro valor de next para prev
              generate(length, prev ++ [head], tail, orig_rules, orig_rules, path, terms, nonterms)
          end
        [{orig, dest} | rules_tail] ->
          # Verificar se o lado esquerdo da regra está contido na entrada
          if Enum.take(next, Enum.count(orig)) == orig do
            new_next = prev ++ dest ++ Enum.drop(next, Enum.count(orig))
            # Evitar loop infinito de substituições
            if Enum.member?(path, new_next) do
              []
            else
              # Substituir regra
              generate(length, [], new_next, orig_rules, orig_rules, path ++ [new_next], terms, nonterms)
            end
          else
            []
          end ++
          # Iterar regras
          generate(length, prev, next, rules_tail, orig_rules, path, terms, nonterms)
      end
    end
  end
end
