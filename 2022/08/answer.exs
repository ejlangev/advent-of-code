defmodule AdventOfCode do
  def solve_part_1(grid) do
    find_visible(Enum.zip_with(grid, &(&1)))
    |> MapSet.to_list
    |> Enum.map(fn {a, b} -> {b, a} end)
    |> then(&MapSet.union(MapSet.new(&1), find_visible(grid)))
    |> Enum.count
  end

  def solve_part_2(grid) do
    find_viewing_distances(Enum.zip_with(grid, &(&1)))
    |> Enum.map(&Map.new(&1, fn {{a, b}, v} -> {{b, a}, v} end))
    |> then(&(&1 ++ find_viewing_distances(grid)))
    |> Enum.reduce(&Map.merge(&1, &2, fn _k, v1, v2 -> v1 * v2 end))
    |> Enum.max_by(&elem(&1, 1))
    |> then(&elem(&1, 1))
  end

  defp find_visible(rows) do
    Enum.with_index(rows)
    |> Enum.reduce(MapSet.new, fn {row, i}, acc ->
      scan_list(acc, Enum.with_index(row), i)
      |> scan_list(Enum.reverse(Enum.with_index(row)), i)
    end)
  end

  defp scan_list(set, row, row_index) do
    Enum.reduce(row, {-1, set}, fn {cell, j}, {max, set} ->
      if cell > max, do: {cell, MapSet.put(set, {row_index, j})}, else: {max, set}
    end)
    |> elem(1)
  end

  defp find_viewing_distances(rows) do
    Enum.with_index(rows)
    |> Enum.flat_map(fn {row, i} ->
      scan_list_for_viewing(Enum.reverse(row), i)
      |> Map.new(fn {{a, b}, v} -> {{a, abs(b - Enum.count(row) + 1)}, v} end)
      |> then(&[&1, scan_list_for_viewing(row, i)])
    end)
  end

  defp scan_list_for_viewing(row, row_index) do
    Enum.reduce(Enum.with_index(row), {Map.new, Map.new}, fn {cell, j}, {lookback, result} ->
      {
        Enum.map(Range.new(0, cell), &({&1, j})) |> Map.new |> then(&Map.merge(lookback, &1)),
        Map.put(result, {row_index, j}, j - Map.get(lookback, cell, 0))
      }
    end)
    |> then(&elem(&1, 1))
  end
end

with {:ok, contents} <- File.read('input.txt') do
  String.split(contents, "\n", trim: true)
  |> Enum.map(fn l -> String.split(l, "", trim: true) |> Enum.map(&String.to_integer/1) end)
  |> tap(&AdventOfCode.solve_part_1(&1) |> IO.inspect(label: "Part 1 Answer"))
  |> AdventOfCode.solve_part_2
  |> IO.inspect(label: "Part 2 Answer")
else
  _ -> IO.inspect("Failed to read input file")
end
