defmodule RTCTest do
  use ExUnit.Case
  doctest RTC

  test "empty relation" do
    rtc = RTC.of([], [:a, :b])
    assert Enum.sort(Keyword.get_values(rtc, :a)) == [:a]
    assert Enum.sort(Keyword.get_values(rtc, :b)) == [:b]
    assert length(rtc) == 2
  end

  test "empty set" do
    assert RTC.of([{:this, :makes}, {:no, :sense}], []) == []
  end

  test "empty relation and set" do
    assert RTC.of([], []) == []
  end

  test "single element" do
    assert RTC.of([{:a, :a}], [:a, :a]) == [{:a, :a}]
  end

  test "reflexive relation" do
    rtc = RTC.of([{:x, :x}, {:y, :y}], [:x, :y])
    assert Enum.sort(Keyword.get_values(rtc, :x)) == [:x]
    assert Enum.sort(Keyword.get_values(rtc, :y)) == [:y]
    assert length(rtc) == 2
  end

  test "transitive relation" do
    rtc = RTC.of([{:m, :n}, {:m, :o}, {:n, :o}], [:m, :n, :o])
    assert Enum.sort(Keyword.get_values(rtc, :m)) == [:m, :n, :o]
    assert Enum.sort(Keyword.get_values(rtc, :n)) == [:n, :o]
    assert Enum.sort(Keyword.get_values(rtc, :o)) == [:o]
    assert length(rtc) == 6
  end

  test "symmetric relation" do
    rtc = RTC.of([{:c, :d}, {:d, :c}], [:c, :d])
    assert Enum.sort(Keyword.get_values(rtc, :c)) == [:c, :d]
    assert Enum.sort(Keyword.get_values(rtc, :d)) == [:c, :d]
    assert length(rtc) == 4
  end

  test "antisymmetric relation" do
    rtc = RTC.of([{:r, :r}, {:r, :s}], [:r, :s, :t])
    assert Enum.sort(Keyword.get_values(rtc, :r)) == [:r, :s]
    assert Enum.sort(Keyword.get_values(rtc, :s)) == [:s]
    assert Enum.sort(Keyword.get_values(rtc, :t)) == [:t]
    assert length(rtc) == 4
  end

  test "loop" do
    rtc = RTC.of([{:a, :b}, {:b, :c}, {:c, :a}], [:a, :b, :c])
    assert Enum.sort(Keyword.get_values(rtc, :a)) == [:a, :b, :c]
    assert Enum.sort(Keyword.get_values(rtc, :b)) == [:a, :b, :c]
    assert Enum.sort(Keyword.get_values(rtc, :c)) == [:a, :b, :c]
    assert length(rtc) == 9
  end

  test "separate parts" do
    rtc = RTC.of([{:h, :i}, {:j, :k}], [:h, :i, :j, :k])
    assert Enum.sort(Keyword.get_values(rtc, :h)) == [:h, :i]
    assert Enum.sort(Keyword.get_values(rtc, :i)) == [:i]
    assert Enum.sort(Keyword.get_values(rtc, :j)) == [:j, :k]
    assert Enum.sort(Keyword.get_values(rtc, :k)) == [:k]
    assert length(rtc) == 6
  end

  test "single origin" do
    rtc = RTC.of([{:w, :x}, {:w, :y}, {:w, :z}], [:w, :x, :y, :z])
    assert Enum.sort(Keyword.get_values(rtc, :w)) == [:w, :x, :y, :z]
    assert Enum.sort(Keyword.get_values(rtc, :x)) == [:x]
    assert Enum.sort(Keyword.get_values(rtc, :y)) == [:y]
    assert Enum.sort(Keyword.get_values(rtc, :z)) == [:z]
    assert length(rtc) == 7
  end
end
