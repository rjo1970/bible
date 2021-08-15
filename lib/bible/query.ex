defmodule Bible.Query do
  def sanitize(query) do
    line = String.replace(query, ~r/\d+:\d+/, "")

    Regex.split(~r/\W/, line)
    |> Enum.filter(fn x -> x != "" end)
    |> Enum.map(&String.downcase/1)
    |> Enum.uniq()
    |> Enum.map(&Stemmer.stem/1)
  end

  def inverse_index(key) do
    read(:inverse_index, key)
  end

  def verse_list(id) do
    read(:verse_list, id)
  end

  def reverse_verse_index(id) do
    read(:reverse_verse_index, id)
  end

  def verse_index(key) do
    read(:verse_index, key)
  end

  def lookup_verse(key) do
    verse_index(key)
    |> read_verse()
  end

  defp read(id, table) do
    case :ets.lookup(id, table) do
      [{_, value}] ->
        value

      [] ->
        []
    end
  end

  def read_verse(id) do
      {id, reverse_verse_index(id),  verse_list(id)}
  end

  def search(query) do
    query
    |> sanitize()
    |> Enum.flat_map(fn word ->
      inverse_index(word)
    end)
    |> Enum.frequencies()
    |> Enum.group_by(fn {_k, v} -> v end)
    |> Enum.sort(&(&1 > &2))
    |> Enum.take(1)
    |> Enum.flat_map(fn {_, list} -> list end)
    |> Enum.sort(fn {k1, v1}, {k2, v2} -> {k2, v1} > {k1, v2} end)
    |> Enum.map(fn {verse_number, _} -> verse_number end)
    |> Enum.map(fn verse_number ->
      {verse_number, reverse_verse_index(verse_number),  verse_list(verse_number)}
    end)
  end
end
