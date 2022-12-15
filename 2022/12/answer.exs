defmodule AdventOfCode do
  @effective_infinity 99999999999999999

  def shortest_path(nodes, initial, goal) do
    distance_map = Map.new(nodes, fn {k, _} -> {k, @effective_infinity} end) |> Map.put(initial, 0)

    find_shortest_path(nodes, [initial], MapSet.new, distance_map)
    |> Map.get(goal)
  end

  def build_nodes(input) do
    node_map = Enum.with_index(input)
    |> Enum.flat_map(fn {row, j} ->
      Enum.with_index(row) |> Enum.map(fn {val, i} -> {{i, j}, val} end)
    end)
    |> Map.new

    Enum.reduce(node_map, %{}, fn {{i, j}, v}, acc ->
      current_node = case v do
        ?S -> ?a
        ?E -> ?z
        _ -> v
      end

      for x <- Range.new(i-1, i+1), y <- Range.new(j-1, j+1),
        x >= 0 and y >= 0,
        y < Enum.count(input) and x < Enum.count(Enum.at(input, 0)),
        x == i or y == j,
        x != i or y != j do
          target_node = case Map.get(node_map, {x, y}) do
            ?S -> ?a
            ?E -> ?z
            _ -> Map.get(node_map, {x, y})
          end

          if abs(target_node - current_node) <= 1 do
            {x, y}
          end
      end
      |> Enum.reject(&is_nil/1)
      |> then(&Map.put(acc, {i,j}, %{key: v, neighbors: &1}))
    end)
  end

  def find_node(nodes, key) do
    Enum.find(nodes, fn {_, v} -> v.key == key end) |> elem(0)
  end

  defp find_shortest_path(nodes, [{c_x, c_y} | tail], used, distance_map) do
    next_points = Map.get(nodes, {c_x, c_y}).neighbors
      |> Enum.reject(&MapSet.member?(used, &1))

    Enum.reduce(next_points, distance_map, fn {x, y}, acc ->
      known_cost = Map.get(acc, {x, y})
      current_path_cost = Map.get(acc, {c_x, c_y})

      if known_cost > current_path_cost + 1, do: Map.put(acc, {x, y}, current_path_cost + 1), else: acc
    end)
    |> then(fn new_distance_map ->
      Enum.uniq(next_points ++ tail)
      |> Enum.sort_by(&Map.get(new_distance_map, &1))
      |> then(&{&1, new_distance_map})
    end)
    |> then(fn
      {[], ndm} -> ndm
      {points, ndm} -> find_shortest_path(nodes, points, MapSet.put(used, List.first(points)), ndm)
    end)
  end
end

with {:ok, contents} <- File.read('input.txt') do
  String.split(contents, "\n", trim: true)
  |> Enum.map(&String.to_charlist/1)
  |> AdventOfCode.build_nodes
  |> tap(fn nodes ->
    AdventOfCode.shortest_path(nodes, AdventOfCode.find_node(nodes, ?S), AdventOfCode.find_node(nodes, ?E))
    |> IO.inspect(label: "Part 1 Answer")
  end)
  |> then(fn nodes ->
    Enum.filter(nodes, fn {_, v} -> v.key == ?a or v.key == ?S end) |> Enum.map(&elem(&1, 0))
    |> Enum.map(&AdventOfCode.shortest_path(nodes, &1, AdventOfCode.find_node(nodes, ?E)))
    |> Enum.min
    |> IO.inspect(label: "Part 2 Answer")
  end)
else
  _ -> IO.inspect("Failed to read input file")
end
