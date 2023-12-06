defmodule AdventOfCode do
  def parse(contents) do
    String.split(contents, "\n", trim: true)
    |> Enum.map(fn line ->
      Regex.scan(~r/(\d+)/, line) |> Enum.map(&List.first(&1) |> String.to_integer)
    end)
    |> Enum.zip
  end

  def solve_part_one([]), do: 1
  def solve_part_one([{time, distance} | rest]) do
    sqrt_term = :math.pow(time, 2) / 4 - distance

    if sqrt_term >= 0 do
      sqrt_value = :math.sqrt(sqrt_term)
      min_value = floor(-1 * sqrt_value + (time / 2) + 1)
      max_value = ceil(sqrt_value + (time / 2) - 1)
      (max_value - min_value + 1) * solve_part_one(rest)
    else
      1 * solve_part_one(rest)
    end
  end

  def solve_part_two(races) do
    Enum.reduce(races, {"", ""}, fn {time, distance}, {s_time, s_distance} ->
      {s_time <> Integer.to_string(time), s_distance <> Integer.to_string(distance)}
    end)
    |> then(fn {time, distance} -> {String.to_integer(time), String.to_integer(distance)} end)
    |> then(&solve_part_one([&1]))
  end
end

with {:ok, contents} <- File.read('input.txt') do
  AdventOfCode.parse(contents)
  |> tap(fn x ->
    AdventOfCode.solve_part_one(x) |> IO.inspect(label: "Part 1")
  end)
  |> AdventOfCode.solve_part_two
  |> IO.inspect(label: "Part 2")
else
  _ -> IO.inspect("Failed to read input file!")
end
