defmodule Bible do
  defdelegate search(query), to: Bible.Query
  defdelegate read_verse(id), to: Bible.Query
end
