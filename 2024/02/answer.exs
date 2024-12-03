defmodule AdventOfCode do
  @spec parse_input(String.t()) :: list(list(Integer.t()))
  def parse_input(input) do
    String.split(input, "\n", trim: true)
    |> Enum.map(fn line ->
      String.split(line, " ") |> Enum.map(&String.to_integer/1)
    end)
  end

  @spec solve_part_one(list(list(Integer.t()))) :: Integer.t()
  def solve_part_one(input) do
    Enum.filter(input, fn report ->
      calculate_diffs(report) |> is_safe_diff_without_dampener?
    end)
    |> Enum.count
  end

  @spec solve_part_two(list(list(Integer.t()))) :: Integer.t()
  def solve_part_two(input) do
    Enum.filter(input, &is_safe_diff_with_dampener?/1)
    |> Enum.filter(&(&1))
    |> Enum.count
  end

  defp calculate_diffs(row) do
    Enum.chunk_every(row, 2, 1, :discard)
    |> Enum.map(fn [a, b] -> b - a end)
  end

  defp is_safe_diff_without_dampener?(diffs) do
    Enum.all?(diffs, &(&1 >= 1 && &1 <= 3)) ||
    Enum.all?(diffs, &(&1 <= -1 && &1 >= -3))
  end

  defp is_safe_diff_with_dampener?(input) do
    if is_safe_diff_without_dampener?(calculate_diffs(input)) do
      true
    else
      Range.new(0, length(input))
      |> Enum.any?(
        &is_safe_diff_without_dampener?(
          calculate_diffs(List.delete_at(input, &1))
        ))
    end
  end
end


with {:ok, contents} <- File.read('input.txt') do
  AdventOfCode.parse_input(contents)
  |> tap(fn input ->
    AdventOfCode.solve_part_one(input) |> IO.inspect(label: "Part 1")
  end)
  |> AdventOfCode.solve_part_two
  |> IO.inspect(label: "Part 2")
else
  _ -> IO.inspect("Failed to read input file!")
end
