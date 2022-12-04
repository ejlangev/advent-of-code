defmodule AdventOfCode do
  def score(input), do: score(input, 0)
  def score([], acc), do: acc
  def score([hd|tl], acc) do
    case hd do
      "A X" -> score(tl, acc + 4)
      "A Y" -> score(tl, acc + 8)
      "A Z" -> score(tl, acc + 3)
      "B X" -> score(tl, acc + 1)
      "B Y" -> score(tl, acc + 5)
      "B Z" -> score(tl, acc + 9)
      "C X" -> score(tl, acc + 7)
      "C Y" -> score(tl, acc + 2)
      "C Z" -> score(tl, acc + 6)
    end
  end

  def decode(entry) do
    case entry do
      "A X" -> "A Z"
      "A Y" -> "A X"
      "A Z" -> "A Y"
      "B X" -> "B X"
      "B Y" -> "B Y"
      "B Z" -> "B Z"
      "C X" -> "C Y"
      "C Y" -> "C Z"
      "C Z" -> "C X"
    end
  end
end

with {:ok, contents} <- File.read('input.txt') do
  String.split(contents, "\n", trim: true)
  |> tap(&AdventOfCode.score(&1) |> IO.inspect(label: "Part 1 Answer"))
  |> Enum.map(&AdventOfCode.decode/1)
  |> AdventOfCode.score
  |> IO.inspect(label: "Part 2 Answer")
else
  _ -> IO.inspect("Failed to read input file")
end
