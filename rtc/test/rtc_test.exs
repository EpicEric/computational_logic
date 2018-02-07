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

  test "symmetric relation" do
    assert RTC.of([{:c, :d}, {:d, :c}], [:c, :d]) ==
      [{:c, :c}, {:c, :d}, {:d, :c}, {:d, :d}]
  end

  test "antisymmetric relation" do
    assert RTC.of([{:r, :r}, {:r, :s}], [:r, :s, :t]) ==
      [{:r, :r}, {:r, :s}, {:s, :s}, {:t, :t}]
  end

  test "loop" do
    assert RTC.of([{:a, :b}, {:b, :c}, {:c, :a}], [:a, :b, :c]) ==
      [{:a, :a}, {:a, :b}, {:a, :c}, {:b, :a}, {:b, :b}, {:b, :c}, {:c, :a}, {:c, :b}, {:c, :c}]
  end

  test "separate parts" do
    assert RTC.of([{:h, :i}, {:j, :k}], [:h, :i, :j, :k]) ==
      [{:h, :h}, {:h, :i}, {:i, :i}, {:j, :j}, {:j, :k}, {:k, :k}]
  end

  test "single origin" do
    assert RTC.of([{:w, :x}, {:w, :y}, {:w, :z}], [:w, :x, :y, :z]) ==
      [{:w, :w}, {:w, :x}, {:w, :y}, {:w, :z}, {:x, :x}, {:y, :y}, {:z, :z}]
  end
end
