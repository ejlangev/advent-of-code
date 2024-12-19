defmodule AdventOfCode do
  @directions [{-1, 0, :north}, {0, 1, :east}, {1, 0, :south}, {0, -1, :west}]

  @spec solve_part_one(String.t()) :: Integer.t()
  def solve_part_one(contents) do
    {{s_i, s_j}, ending, direction, points} = parse_input(contents)

    run_dijkstras({s_i, s_j}, direction, points)
    |> elem(0)
    |> then(fn final_distances ->
      in_all_directions(ending) |> Enum.map(&Map.fetch!(final_distances, &1)) |> Enum.min
    end)
  end

  @spec solve_part_two(String.t()) :: Integer.t()
  def solve_part_two(contents) do
    {{s_i, s_j}, {e_i, e_j}, direction, points} = parse_input(contents)

    run_dijkstras({s_i, s_j}, direction, points)
    |> then(fn {distances, paths} ->
      shortest_path = in_all_directions({e_i, e_j})
      |> Enum.min_by(&Map.fetch!(distances, &1))
      |> then(&Map.fetch!(paths, &1))

      find_all_path_tiles(points, paths, distances, shortest_path, MapSet.new)
    end)
    |> MapSet.size
  end

  defp parse_input(contents) do
    String.split(contents, "\n", trim: true)
    |> Enum.with_index
    |> Enum.reduce({nil, nil, MapSet.new}, fn {line, i}, outer_acc ->
      String.split(line, "", trim: true)
      |> Enum.with_index
      |> Enum.reduce(outer_acc, fn {val, j}, {start, ending, points} ->
        case val do
          "#" -> {start, ending, points}
          "." -> {start, ending, MapSet.put(points, {i, j})}
          "S" -> {{i, j}, ending, MapSet.put(points, {i, j})}
          "E" -> {start, {i, j}, MapSet.put(points, {i, j})}
        end
      end)
    end)
    |> Tuple.insert_at(2, :east)
  end

  defp run_dijkstras({s_i, s_j}, direction, points) do
    distances = Enum.flat_map(points, &in_all_directions/1)
    |> Enum.map(&{&1, :infinity})
    |> Enum.into(%{})
    |> Map.put({s_i, s_j, direction}, 0)

    paths = Enum.flat_map(points, &in_all_directions/1)
    |> Enum.into(%{}, &{&1, []})
    |> Map.put({s_i, s_j, direction}, [{s_i, s_j, direction}])

    unvisited = Enum.flat_map(points, &in_all_directions/1) |> MapSet.new

    dijkstras(points, distances, paths, unvisited)
  end

  defp dijkstras(nodes, distances, paths, unvisited) do
    if MapSet.size(unvisited) == 0 do
      {distances, paths}
    else
      {c_i, c_j, direction} = Enum.min_by(unvisited, &Map.fetch!(distances, &1))
      current_distance = Map.fetch!(distances, {c_i, c_j, direction})

      Enum.map(@directions, fn {d_i, d_j, dir} -> {c_i + d_i, c_j + d_j, dir} end)
      |> Enum.filter(&MapSet.member?(nodes, {elem(&1, 0), elem(&1, 1)}) && MapSet.member?(unvisited, &1))
      |> Enum.map(fn {i, j, dir} ->
        if dir == direction do
          {i, j, dir, 1}
        else
          {i, j, dir, 1000 * (abs(j - c_j) + abs(i - c_i)) + 1}
        end
      end)
      |> Enum.reduce({distances, paths}, fn {i, j, dir, cost}, {distance_acc, path_acc} ->
        new_distance = current_distance + cost

        if new_distance <= Map.fetch!(distance_acc, {i, j, dir}) do
          {
            Map.put(distance_acc, {i, j, dir}, new_distance),
            Map.put(path_acc, {i, j, dir}, [{i, j, dir} | Map.fetch!(path_acc, {c_i, c_j, direction})])
          }
        else
          {distance_acc, path_acc}
        end
      end)
      |> then(&dijkstras(nodes, elem(&1, 0), elem(&1, 1), MapSet.delete(unvisited, {c_i, c_j, direction})))
    end
  end

  defp in_all_directions({i, j}) do
    [{i, j, :north}, {i, j, :south}, {i, j, :east}, {i, j, :west}]
  end

  defp find_all_path_tiles(_, _, _, [], _) do MapSet.new end
  defp find_all_path_tiles(nodes, paths, distances, [{c_i, c_j, direction} | rest], visited) do
    remaining = MapSet.new(rest)

    Enum.flat_map(@directions, fn {d_i, d_j, _} -> in_all_directions({c_i + d_i, c_j + d_j}) end)
    |> Enum.filter(&MapSet.member?(nodes, {elem(&1, 0), elem(&1, 1)}) && !MapSet.member?(visited, {elem(&1, 0), elem(&1, 1)}))
    |> Enum.filter(&!MapSet.member?(remaining, &1))
    |> Enum.map(fn {i, j, dir} ->
      if dir == direction do
        {i, j, dir, 1}
      else
        {i, j, dir, 1000 * (abs(j - c_j) + abs(i - c_i)) + 1}
      end
    end)
    |> Enum.filter(fn {i, j, dir, cost} ->
      distance = Map.fetch!(distances, {i, j, dir})
      distance != :infinity && (distance + cost) <= Map.fetch!(distances, {c_i, c_j, direction})
    end)
    |> Enum.reduce(MapSet.new([{c_i, c_j}]), fn {i, j, dir, _}, acc ->
      path = Map.get(paths, {i, j, dir}, [])

      find_all_path_tiles(nodes, paths, distances, path, MapSet.put(visited, {c_i, c_j}))
      |> MapSet.union(acc)
    end)
    |> then(fn others ->
      find_all_path_tiles(nodes, paths, distances, rest, MapSet.put(visited, {c_i, c_j}))
      |> MapSet.union(others)
    end)
  end
end


with {:ok, contents} <- File.read("input.txt") do
  AdventOfCode.solve_part_one(contents) |> IO.inspect(label: "Part 1")
  AdventOfCode.solve_part_two(contents) |> IO.inspect(label: "Part 2")
else
  _ -> IO.inspect("Failed to read input file!")
end
