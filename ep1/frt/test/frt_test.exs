defmodule FRTTest do
  use ExUnit.Case
  doctest FRT

  test "empty relation" do
    frt = FRT.of([], [:a, :b])
    assert Enum.sort(Keyword.get_values(frt, :a)) == [:a]
    assert Enum.sort(Keyword.get_values(frt, :b)) == [:b]
    assert length(frt) == 2
  end

  test "empty set" do
    assert FRT.of([{:this, :makes}, {:no, :sense}], []) == []
  end

  test "empty relation and set" do
    assert FRT.of([], []) == []
  end

  test "single element" do
    assert FRT.of([{:a, :a}], [:a, :a]) == [{:a, :a}]
  end

  test "reflexive relation" do
    frt = FRT.of([{:x, :x}, {:y, :y}], [:x, :y])
    assert Enum.sort(Keyword.get_values(frt, :x)) == [:x]
    assert Enum.sort(Keyword.get_values(frt, :y)) == [:y]
    assert length(frt) == 2
  end

  test "transitive relation" do
    frt = FRT.of([{:m, :n}, {:m, :o}, {:n, :o}], [:m, :n, :o])
    assert Enum.sort(Keyword.get_values(frt, :m)) == [:m, :n, :o]
    assert Enum.sort(Keyword.get_values(frt, :n)) == [:n, :o]
    assert Enum.sort(Keyword.get_values(frt, :o)) == [:o]
    assert length(frt) == 6
  end

  test "symmetric relation" do
    frt = FRT.of([{:c, :d}, {:d, :c}], [:c, :d])
    assert Enum.sort(Keyword.get_values(frt, :c)) == [:c, :d]
    assert Enum.sort(Keyword.get_values(frt, :d)) == [:c, :d]
    assert length(frt) == 4
  end

  test "antisymmetric relation" do
    frt = FRT.of([{:r, :r}, {:r, :s}], [:r, :s, :t])
    assert Enum.sort(Keyword.get_values(frt, :r)) == [:r, :s]
    assert Enum.sort(Keyword.get_values(frt, :s)) == [:s]
    assert Enum.sort(Keyword.get_values(frt, :t)) == [:t]
    assert length(frt) == 4
  end
end
