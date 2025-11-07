defmodule PfTest do
  use ExUnit.Case
  doctest Pf

  test "greets the world" do
    assert Pf.hello() == :world
  end
end
