defmodule RTCTest do
  use ExUnit.Case
  doctest RTC

  test "empty relation" do
    assert RTC.of([], [:a, :b]) ==
      [{:a, :a}, {:b, :b}]
  end

  test "empty set" do
    assert RTC.of([{:this, :makes}, {:no, :sense}], []) ==
      []
  end

  test "empty relation and set" do
    assert RTC.of([], []) ==
      []
  end

  test "element not in set" do
    assert RTC.of([{:a, 2}, {2, :b}], [:a, :b]) ==
      [{:a, :a}, {:b, :b}]
  end

  test "single element" do
    assert RTC.of([{:a, :a}], [:a, :a]) ==
      [{:a, :a}]
  end

  test "reflexive relation" do
    assert RTC.of([{:x, :x}, {:y, :y}], [:x, :y]) ==
      [{:x, :x}, {:y, :y}]
  end

  test "transitive relation" do
    assert RTC.of([{:m, :n}, {:m, :o}, {:n, :o}], [:m, :n, :o]) ==
      [{:m, :m}, {:m, :n}, {:m, :o}, {:n, :n}, {:n, :o}, {:o, :o}]
  end

  test "reflexive-transitive relation" do
    assert RTC.of([{:x, :x}, {:x, :y}, {:y, :y}], [:x, :y]) ==
      [{:x, :x}, {:x, :y}, {:y, :y}]
  end

  test "symmetric relation" do
    assert RTC.of([{:c, :d}, {:d, :c}], [:c, :d]) ==
      [{:c, :c}, {:c, :d}, {:d, :c}, {:d, :d}]
  end

  test "antisymmetric relation" do
    assert RTC.of([{:r, :r}, {:r, :s}], [:r, :s, :t]) ==
      [{:r, :r}, {:r, :s}, {:s, :s}, {:t, :t}]
  end

  test "loops" do
    assert RTC.of([{:a, :b}, {:b, :a}, {:b, :c}, {:c, :a}], [:a, :b, :c]) ==
      [{:a, :a}, {:a, :b}, {:a, :c}, {:b, :a}, {:b, :b}, {:b, :c}, {:c, :a}, {:c, :b}, {:c, :c}]
  end

  test "separate parts" do
    rtc = RTC.of([{:h, :i}, {:j, :k}], [:h, :i, :j, :k])
    assert rtc == [{:h, :h}, {:h, :i}, {:i, :i}, {:j, :j}, {:j, :k}, {:k, :k}]
    assert rtc == RTC.of([{:h, :i}], [:h, :i]) ++ RTC.of([{:j, :k}], [:j, :k])
  end

  test "multiple paths" do
    assert RTC.of([{:w, :x}, {:w, :y}, {:x, :z}, {:y, :z}], [:w, :x, :y, :z]) ==
      [{:w, :w}, {:w, :x}, {:w, :y}, {:w, :z}, {:x, :x}, {:x, :z}, {:y, :y}, {:y, :z}, {:z, :z}]
  end

  test "single origin" do
    assert RTC.of([{:w, :x}, {:w, :y}, {:w, :z}], [:w, :x, :y, :z]) ==
      [{:w, :w}, {:w, :x}, {:w, :y}, {:w, :z}, {:x, :x}, {:y, :y}, {:z, :z}]
  end

  test "ignore order of relation" do
    assert RTC.of([{:a, :b}, {:b, :c}], [:a, :b, :c]) ==
      RTC.of([{:b, :c}, {:a, :b}], [:a, :b, :c])
  end

  test "ignore order of set" do
    assert RTC.of([{:a, :b}, {:b, :c}], [:a, :b, :c]) ==
      RTC.of([{:a, :b}, {:b, :c}], [:b, :c, :a])
  end

  test "mixed types" do
    assert RTC.of([{:a, 1}, {:a, []}], [1, :a, []]) ==
      [{1, 1}, {:a, 1}, {:a, :a}, {:a, []}, {[], []}]
  end
end
