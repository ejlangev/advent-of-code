defmodule AdventOfCode do
  @spec extract_number(String.t(), %{String.t() => integer()}) :: integer()
  def extract_number(s, replacements) do
    Enum.reduce(replacements, s, fn {k, v}, acc -> Regex.replace(~r/(#{k})/, acc, "#{k}#{v}#{k}") end)
    |> then(&Regex.replace(~r/[^\d]/, &1, ""))
    |> String.split("", trim: true)
    |> then(fn x -> case x do
      [] -> 0
      _ -> String.to_integer(List.first(x) <> List.last(x))
    end
    end)
  end
end

with {:ok, contents} <- File.read('input.txt') do
  lines = String.split(contents, "\n", trim: true)

  Enum.map(lines, &AdventOfCode.extract_number(&1, %{}))
  |> Enum.sum
  |> IO.inspect(label: "Part 1")

  Enum.map(lines, &AdventOfCode.extract_number(&1, %{
    "one" => "1",
    "two" => "2",
    "three" => "3",
    "four" => "4",
    "five" => "5",
    "six" => "6",
    "seven" => "7",
    "eight" => "8",
    "nine" => "9"
  }))
  |> Enum.sum
  |> IO.inspect(label: "Part 2")
else
  _ -> IO.inspect("Failed to read input file!")
end
