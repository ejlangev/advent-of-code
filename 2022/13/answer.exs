defmodule AdventOfCode do
  def pair_ordering([], []), do: :unknown
  def pair_ordering([], _), do: :correct
  def pair_ordering(_, []), do: :incorrect
  def pair_ordering([l | l_tl], [r | r_tl]) when is_number(l) and is_number(r) do
    cond do
      l < r -> :correct
      l == r -> pair_ordering(l_tl, r_tl)
      true -> :incorrect
    end
  end
  def pair_ordering([l | l_tl], [r | r_tl]) when is_number(l) and is_list(r) do
    case pair_ordering([l], r) do
      :unknown -> pair_ordering(l_tl, r_tl)
      x -> x
    end
  end
  def pair_ordering([l | l_tl], [r | r_tl]) when is_list(l) and is_number(r) do
    case pair_ordering(l, [r]) do
      :unknown -> pair_ordering(l_tl, r_tl)
      x -> x
    end
  end
  def pair_ordering([l | l_tl], [r | r_tl]) when is_list(l) and is_list(r) do
    case pair_ordering(l, r) do
      :unknown -> pair_ordering(l_tl, r_tl)
      x -> x
    end
  end
end

with {:ok, contents} <- File.read('input.txt') do
  String.split(contents, "\n\n", trim: true)
  |> Enum.map(fn x ->
    String.split(x, "\n", trim: true) |> Enum.map(&Code.eval_string(&1, []) |> elem(0)) |> List.to_tuple
  end)
  |> tap(fn pairs ->
    Enum.map(pairs, &AdventOfCode.pair_ordering(elem(&1, 0), elem(&1, 1)))
    |> Enum.with_index
    |> Enum.filter(&elem(&1, 0) == :correct)
    |> Enum.map(&elem(&1, 1) + 1)
    |> Enum.sum
    |> IO.inspect(label: "Part 1 Answer")
  end)
  |> Enum.reduce([[[2]], [[6]]], fn elm, acc -> acc ++ Tuple.to_list(elm) end)
  |> Enum.sort(fn l, r -> AdventOfCode.pair_ordering(l, r) == :correct end)
  |> then(fn res ->
    (Enum.find_index(res, &(&1 == [[2]])) + 1) * (Enum.find_index(res, &(&1 == [[6]])) + 1)
  end)
  |> IO.inspect(label: "Part 2 Answer")
else
  _ -> IO.inspect("Failed to read input file")
end
