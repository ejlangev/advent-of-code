defmodule AdventOfCode do
  @transforms [{-1, 0}, {0, 1}, {1, 0}, {0, -1}]

  @spec solve_part_one(String.t()) :: Integer.t()
  def solve_part_one(contents) do
    {map, trailheads} = parse_input(contents)

    Enum.map(trailheads, &explore_trailhead(map, &1))
    |> Enum.map(&count_nines(map, &1))
    |> Enum.sum
  end

  @spec solve_part_two(String.t()) :: Integer.t()
  def solve_part_two(contents) do
    {map, trailheads} = parse_input(contents)

    Enum.map(trailheads, &explore_rating(map, &1))
    |> Enum.sum
  end

  defp parse_input(contents) do
    map = String.split(contents, "\n", trim: true)
    |> Enum.map(fn l -> String.split(l, "", trim: true) |> Enum.map(&String.to_integer/1) end)

    Enum.with_index(map)
    |> Enum.reduce([], fn {row, i}, acc ->
      Enum.with_index(row)
      |> Enum.reduce(acc, fn {val, j}, inner_acc ->
        if val == 0, do: [{i,j} | inner_acc], else: inner_acc
      end)
    end)
    |> then(&{map, &1})
  end

  defp explore_trailhead(map, {t_i, t_j}, used \\ MapSet.new) do
    valid_next_steps(map, {t_i, t_j}, used)
    |> Enum.map(&explore_trailhead(map, &1, MapSet.put(used, &1)))
    |> Enum.reduce(used, &MapSet.union(&1, &2))
  end

  defp explore_rating(map, {t_i, t_j}, used \\ MapSet.new) do
    curr_val = Enum.at(Enum.at(map, t_i), t_j)
    to_add = if curr_val == 9, do: 1, else: 0

    valid_next_steps(map, {t_i, t_j}, used)
    |> Enum.map(&explore_rating(map, &1, MapSet.put(used, {&1})))
    |> Enum.reduce(to_add, &(&1 + &2))
  end

  defp count_nines(map, points) do
    Enum.filter(points, fn {i, j} -> Enum.at(Enum.at(map, i), j) == 9 end)
    |> Enum.count
  end

  defp valid_next_steps(map, {t_i, t_j}, used) do
    n_rows = length(map)
    n_cols = length(Enum.at(map, 0))
    curr_val = Enum.at(Enum.at(map, t_i), t_j)

    Enum.map(@transforms, fn {d_i, d_j} -> {t_i + d_i, t_j + d_j} end)
    |> Enum.filter(fn {i, j} ->
      i >= 0 && i < n_rows && j >= 0 && j < n_cols
      && Enum.at(Enum.at(map, i), j) == (curr_val + 1)
      && !MapSet.member?(used, {i, j})
    end)
  end
end


with {:ok, contents} <- File.read("input.txt") do
  AdventOfCode.solve_part_one(contents) |> IO.inspect(label: "Part 1")
  AdventOfCode.solve_part_two(contents) |> IO.inspect(label: "Part 2")
else
  _ -> IO.inspect("Failed to read input file!")
end
