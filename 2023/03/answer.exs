defmodule AdventOfCode do
  def parse(contents) do
    String.split(contents, "\n", trim: true)
    |> Enum.with_index
    |> Enum.reduce({%{}, %{}}, fn {row, i}, {num_map, sym_map} ->
      new_sym = Regex.scan(~r/[^0-9\.]/, row, return: :index)
      |> Enum.map(&List.first/1)
      |> Enum.reduce(sym_map, fn {j, _}, acc -> Map.put(acc, {i, j}, String.at(row, j)) end)

      new_num = Regex.scan(~r/\d+/, row, return: :index)
      |> Enum.map(&List.first/1)
      |> Enum.reduce(num_map, fn {j, l}, acc ->
        String.slice(row, Range.new(j, j + l - 1))
        |> then(&Map.put(acc, {i, j, l}, String.to_integer(&1)))
      end)

      {new_num, new_sym}
    end)
  end

  def solve_part_one({num_map, syms}) do
    map_keys = MapSet.new(Map.keys(syms))
    Enum.filter(Map.keys(num_map), fn {i, j, l} ->
      for y <- Range.new(i - 1, i + 1), x <- Range.new(j - 1, j + l),
        !(y == i and x >= j and x < j + l)
       do
          MapSet.member?(map_keys, {y, x})
      end
      |> Enum.any?
    end)
    |> Enum.map(&Map.fetch!(num_map, &1))
    |> Enum.sum
  end

  def solve_part_two({num_map, syms}) do
    adjacent_map = Enum.reduce(num_map, %{}, fn {{i, j, l}, num}, acc ->
      for y <- Range.new(i - 1, i + 1), x <- Range.new(j - 1, j + l),
        !(y == i and x >= j and x < j + l)
       do
          {y, x}
      end
      |> Enum.reduce(acc, &Map.update(&2, &1, [num], fn prev -> [num | prev] end))
    end)

    Enum.reduce(syms, 0, fn {k, v}, acc ->
      adjacency = Map.get(adjacent_map, k, [])
      if v == "*" and length(adjacency) == 2 do
        Enum.product(adjacency) + acc
      else
        acc
      end
    end)
  end
end

with {:ok, contents} <- File.read('input.txt') do
  AdventOfCode.parse(contents)
  |> tap(fn results ->
    AdventOfCode.solve_part_one(results)
    |> IO.inspect(label: "Part 1")
  end)
  |> AdventOfCode.solve_part_two
  |> IO.inspect(label: "Part 2")
else
  _ -> IO.inspect("Failed to read input file!")
end
