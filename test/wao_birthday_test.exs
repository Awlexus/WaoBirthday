defmodule WaoBirthdayTest do
  use ExUnit.Case
  doctest WaoBirthday

  test "greets the world" do
    assert WaoBirthday.hello() == :world
  end
end
