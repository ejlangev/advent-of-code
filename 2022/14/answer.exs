defmodule AdventOfCode do
  def solve(paths, horizontal_offset \\ -1) do
    used = Enum.reduce(paths, MapSet.new, fn {{x1, y1}, {x2, y2}}, acc ->
      (for x <- Range.new(x1, x2), y <- Range.new(y1, y2), do: {x, y})
      |> MapSet.new
      |> MapSet.union(acc)
    end)

    max_x = Enum.max_by(used, &elem(&1, 0)) |> elem(0)
    max_y = Enum.max_by(used, &elem(&1, 1)) |> elem(1)

    final_used = if horizontal_offset > 0 do
      Enum.map(Range.new(0, 5000), &{&1, max_y + horizontal_offset})
      |> MapSet.new
      |> MapSet.union(used)
    else
      used
    end

    Stream.unfold(final_used, fn
      x when is_nil(x) -> nil
      set ->
        Stream.unfold({500, 0}, fn
          x when is_nil(x) -> nil
          {x, y} when horizontal_offset < 0 and (x > max_x or y > max_y) -> {nil, nil}
          {x, y} -> cond do
            !MapSet.member?(set, {x, y + 1}) -> {{x, y}, {x, y + 1}}
            !MapSet.member?(set, {x - 1, y + 1}) -> {{x, y}, {x - 1, y + 1}}
            !MapSet.member?(set, {x + 1, y + 1}) -> {{x, y}, {x + 1, y + 1}}
            true -> {{x, y}, nil}
          end
        end)
        |> Enum.to_list
        |> List.last
        |> then(fn
          nil -> {0, nil}
          {500, 0} -> {1, nil}
          entry -> {1, MapSet.put(set, entry)}
        end)
    end)
    |> Enum.sum
  end
end

with {:ok, contents} <- File.read('input.txt') do
  String.split(contents, "\n", trim: true)
  |> Enum.map(fn line ->
    String.split(line, " -> ", trim: true)
    |> Enum.map(fn e -> String.split(e, ",") |> Enum.map(&String.to_integer/1) |> List.to_tuple end)
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(&List.to_tuple/1)
  end)
  |> List.flatten
  |> tap(fn x ->
    AdventOfCode.solve(x) |> IO.inspect(label: "Part 1 Answer")
  end)
  |> AdventOfCode.solve(2)
  |> IO.inspect(label: "Part 2 Answer")
else
  _ -> IO.inspect("Failed to read input file")
end
