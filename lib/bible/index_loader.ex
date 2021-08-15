defmodule Bible.IndexLoader do
  def load_indexes() do
    load_inverse_index()
    load_verse_list()
    load_reverse_verse_index()
  end

  def load_inverse_index() do
    read_inverse_index()
    |> insert("inverse_index")
  end

  def load_verse_list() do
    read_verse_list()
    |> Enum.with_index()
    |> Enum.map(fn {v, k} -> {k, v} end)
    |> insert("verse_list")
  end

  def load_reverse_verse_index() do
    reverse_data = read_reverse_verse_index()

    reverse_data
    |> insert("reverse_verse_index")

    reverse_data
    |> Enum.map(fn {v, k} -> {k, v} end)
    |> insert("verse_index")
  end

  def read_inverse_index do
    "../data/inverse_index.data"
    |> read_data()
  end

  def read_verse_list() do
    "../data/verse_list.data"
    |> read_data()
  end

  def read_reverse_verse_index() do
    "../data/reverse_verse_index.data"
    |> read_data()
  end

  defp read_data(path) do
    path
    |> Path.expand(__DIR__)
    |> File.read!()
    |> :zlib.gunzip()
    |> :erlang.binary_to_term()
  end

  defp insert(data, table) do
    table_name = String.to_atom(table)
    :ets.new(table_name, [:ordered_set, :protected, :named_table])

    Enum.each(data, fn {key, value} ->
      :ets.insert_new(table_name, {key, value})
    end)
  end
end
