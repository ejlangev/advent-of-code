defmodule AdventOfCode do
  @directions [{-1, 0}, {0, 1}, {1, 0}, {0, -1}]

  @spec solve_part_one(String.t()) :: Integer.t()
  def solve_part_one(contents) do
    map = parse_input(contents)

    build_regions(map)
    |> Enum.map(&calculate_perimeter(map, &1) * MapSet.size(&1))
    |> Enum.sum
  end

  @spec solve_part_two(String.t()) :: Integer.t()
  def solve_part_two(contents) do
    map = parse_input(contents)

    build_regions(map)
    |> Enum.map(&calculate_sides(map, &1) * MapSet.size(&1))
    |> Enum.sum
  end


  defp parse_input(contents) do
    String.split(contents, "\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
  end

  defp build_regions(map) do
    Enum.with_index(map)
    |> Enum.reduce(Map.new, fn {row, i}, outer_acc ->
      Enum.with_index(row)
      |> Enum.reduce(outer_acc, fn {val, j}, acc ->
        adjacent_squares = adjacent_squares(map, {i, j}) |> MapSet.new

        {matched, unmatched} = Map.get(acc, val, [])
        |> Enum.split_with(fn set -> MapSet.size(MapSet.intersection(set, adjacent_squares)) > 0 end)

        Enum.reduce(matched, MapSet.new, &MapSet.union(&1, &2))
        |> then(&[MapSet.put(&1, {i,j}) | unmatched])
        |> then(&Map.put(acc, val, &1))
      end)
    end)
    |> Map.values
    |> List.flatten
  end

  defp calculate_perimeter(map, points) do
    Enum.map(points, fn {i, j} ->
      adjacent_squares(map, {i, j})
      |> Enum.count(&MapSet.member?(points, &1))
      |> then(&(4 - &1))
    end)
    |> Enum.sum
  end

  defp calculate_sides(map, points) do
    Enum.map(points, &(
      adjacent_squares(map, &1, true)
      |> MapSet.new
      |> MapSet.difference(points)
      |> then(fn a -> {&1, MapSet.to_list(a)} end)
    ))
    |> Enum.reduce({Map.new, Map.new}, fn {{i, j}, open_points}, outer_acc ->
      Enum.reduce(open_points, outer_acc, fn {t_i, t_j}, {row_map, col_map} ->
        if t_i == i do
          {row_map, Map.put(col_map, {j, t_j}, MapSet.put(Map.get(col_map, {j, t_j}, MapSet.new), t_i))}
        else
          {Map.put(row_map, {i, t_i}, MapSet.put(Map.get(row_map, {i, t_i}, MapSet.new), t_j)), col_map}
        end
      end)
    end)
    |> Tuple.to_list
    |> Enum.flat_map(&Map.values/1)
    |> Enum.map(&count_gaps/1)
    |> Enum.sum
  end

  defp adjacent_squares(map, {i, j}, allow_outside_bounds \\ false) do
    Enum.map(@directions, fn {d_i, d_j} -> {i + d_i, j + d_j} end)
    |> Enum.filter(fn {t_i, t_j} -> allow_outside_bounds || (t_i >= 0 && t_i < length(map) && t_j >= 0 && t_j < length(Enum.at(map, 0))) end)
  end

  defp count_gaps(values) do
    Enum.sort(values)
    |> Enum.reduce({-100, 0}, fn val, {last, total} ->
      {val, total + (if val == last + 1, do: 0, else: 1)}
    end)
    |> elem(1)
  end
end


with {:ok, contents} <- File.read("input.txt") do
  AdventOfCode.solve_part_one(contents) |> IO.inspect(label: "Part 1")
  AdventOfCode.solve_part_two(contents) |> IO.inspect(label: "Part 2")
else
  _ -> IO.inspect("Failed to read input file!")
end
