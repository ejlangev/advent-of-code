defmodule AdventOfCode do
  def solve_part_1(sensors, y) do
    used = Enum.flat_map(sensors, &[elem(&1, 0), elem(&1, 1)]) |> MapSet.new
    max_distance = Enum.max_by(sensors, &elem(&1, 2)) |> elem(2)

    Enum.min_max_by(sensors, fn {_, {bx, _}, _} -> bx end)
    |> then(fn {{_, {min, _}, _}, {_, {max, _}, _}} -> Range.new(min - (3 * max_distance), max + (3 * max_distance)) end)
    |> Enum.reduce(0, fn x, acc -> cond do
      MapSet.member?(used, {x, y}) -> acc
      Enum.any?(sensors, fn {{sx, sy}, _, d} -> (abs(sx - x) + abs(sy - y)) <= d end) -> acc + 1
      true -> acc
    end end)
  end

  def solve_part_2(sensors, min, max) do
    Enum.reduce(sensors, MapSet.new, fn {{x_i, y_i}, _, d}, acc ->
      Enum.reduce(Range.new(x_i - d - 1, x_i + d + 1), acc, fn x, inner ->
        MapSet.put(
          MapSet.put(inner, {x, y_i - (d - abs(x_i - x) + 1)}),
          {x, y_i + (d - abs(x_i - x) + 1)}
        )
      end)
    end)
    |> Enum.filter(fn {x, y} -> x >= min and x <= max and y >= min and y <= max end)
    |> Enum.find(fn {x, y} -> Enum.all?(sensors, fn {{s_x, s_y}, _, d} -> (abs(s_x - x) + abs(s_y - y)) > d end) end)
    |> then(fn {x, y} -> x * 4000000 + y end)
  end
end

with {:ok, contents} <- File.read('input.txt') do
  String.split(contents, "\n", trim: true)
  |> Enum.map(fn l ->
    Regex.run(~r/^Sensor at x=([\d\-]+), y=([\d\-]+): closest beacon is at x=([\d\-]+), y=([\d\-]+)$/, l)
    |> Enum.drop(1)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple
    |> then(fn {sx, sy, bx, by} -> {{sx, sy}, {bx, by}, abs(bx - sx) + abs(by - sy)} end)
  end)
  |> tap(fn l ->
    AdventOfCode.solve_part_1(l, 2000000) |> IO.inspect(label: "Part 1 Answer")
  end)
  |> AdventOfCode.solve_part_2(0, 4000000)
  |> IO.inspect(label: "Part 2 Answer")
else
  _ -> IO.inspect("Failed to read input file")
end
