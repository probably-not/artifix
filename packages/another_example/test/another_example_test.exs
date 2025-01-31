defmodule AnotherExampleTest do
  use ExUnit.Case
  doctest AnotherExample

  test "greets the world" do
    assert AnotherExample.hello() == :world
  end
end
