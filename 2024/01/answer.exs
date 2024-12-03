defmodule AdventOfCode do
  @spec solve_part_one(list(Integer.t()), list(Integer.t())) :: Integer.t()
  def solve_part_one(left, right) do
    Enum.zip(Enum.sort(left), Enum.sort(right))
    |> Enum.map(fn {x, y} -> abs(x - y) end)
    |> Enum.sum
  end

  @spec solve_part_two(list(Integer.t()), list(Integer.t())) :: Integer.t()
  def solve_part_two(left, right) do
    frequencies = Enum.reduce(right, %{}, fn val, acc ->
      Map.update(acc, val, 1, fn x -> x + 1 end)
    end)

    Enum.map(left, &Map.get(frequencies, &1, 0) * &1)
    |> Enum.sum
  end
end

with {:ok, contents} <- File.read('input.txt') do
  String.split(contents, "\n", trim: true)
  |> Enum.reduce({[], []}, fn line, {left, right} ->
    String.split(line, " ", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> then(fn vals ->
      {[Enum.at(vals, 0) | left], [Enum.at(vals, 1) | right]}
    end)
  end)
  |> tap(fn {left, right} ->
    AdventOfCode.solve_part_one(left, right) |> IO.inspect(label: "Part 1")
  end)
  |> then(fn {left, right} -> AdventOfCode.solve_part_two(left, right) end)
  |> IO.inspect(label: "Part 2")
else
  _ -> IO.inspect("Failed to read input file!")
end
