defmodule AdventOfCode do
  def score(input) do
    Enum.map(input, &MapSet.new(String.codepoints(&1)))
    |> Enum.reduce(&MapSet.intersection/2)
    |> Enum.at(0)
    |> String.to_charlist
    |> Enum.map(&(1 + &1 - (if &1 >= ?a, do: ?a, else: (?A - 26))))
    |> Enum.at(0)
  end
end

with {:ok, contents} <- File.read('input.txt') do
  String.split(contents, "\n", trim: true)
  |> tap(fn lines ->
    Enum.map(lines, &String.split_at(&1, trunc(String.length(&1) / 2)))
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&AdventOfCode.score/1)
    |> Enum.sum
    |> IO.inspect(label: "Part 1 Answer")
  end)
  |> Enum.chunk_every(3)
  |> Enum.map(&AdventOfCode.score/1)
  |> Enum.sum
  |> IO.inspect(label: "Part 2 Answer")
else
  _ -> IO.inspect("Failed to read input file")
end
