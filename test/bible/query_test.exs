defmodule Bible.QueryTest do
  use ExUnit.Case, async: true

  alias Bible.Query

  test "sanitize queries" do
    assert Query.sanitize("Earthly 3:16 Delights") == ["earth", "delight"]
  end
end
