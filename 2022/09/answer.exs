defmodule AdventOfCode do
  def solve(moves) do
    Enum.flat_map(moves, fn {d, a} -> List.duplicate(d, a) end)
    |> Enum.reduce({{0, 0}, {0, 0}, []}, fn direction, {{h_x, h_y}, {t_x, t_y}, set} ->
      {new_h_x, new_h_y} = new_head = case direction do
        "R" -> {h_x + 1, h_y}
        "L" -> {h_x - 1, h_y}
        "U" -> {h_x, h_y + 1}
        "D" -> {h_x, h_y - 1}
        "LU" -> {h_x - 1, h_y + 1}
        "RU" -> {h_x + 1, h_y + 1}
        "LD" -> {h_x - 1, h_y - 1}
        "RD" -> {h_x + 1, h_y - 1}
      end
      new_tail = cond do
        abs(new_h_x - t_x) <= 1 && abs(new_h_y - t_y) <= 1 -> {t_x, t_y}
        new_h_x == t_x -> {t_x, (if new_h_y > t_y, do: new_h_y - 1, else: new_h_y + 1)}
        new_h_y == t_y -> {(if new_h_x > t_x, do: new_h_x - 1, else: new_h_x + 1), t_y}
        true -> {(if new_h_x > t_x, do: t_x + 1, else: t_x - 1), (if new_h_y > t_y, do: t_y + 1, else: t_y - 1)}
      end

      {new_head, new_tail, [new_tail | set]}
    end)
    |> then(&elem(&1, 2))
    |> Enum.reverse
  end

  def positions_to_moves(positions) do
    Enum.reduce(positions, {{0, 0}, []}, fn {new_x, new_y} = new_position, {{last_x, last_y}, moves} ->
      move = cond do
        new_x == last_x && new_y == last_y -> nil
        new_x == last_x -> if new_y > last_y, do: "U", else: "D"
        new_y == last_y -> if new_x > last_x, do: "R", else: "L"
        new_x > last_x -> if new_y > last_y, do: "RU", else: "RD"
        new_x < last_x -> if new_y > last_y, do: "LU", else: "LD"
      end

      {new_position, (if move == nil, do: moves, else: [{move, 1} | moves])}
    end)
    |> then(&elem(&1, 1))
    |> Enum.reverse
  end
end

with {:ok, contents} <- File.read('input.txt') do
  String.split(contents, "\n", trim: true)
  |> Enum.map(&String.split(&1, " ", trim: true) |> then(fn l -> {Enum.at(l, 0), String.to_integer(Enum.at(l, 1))} end))
  |> tap(&AdventOfCode.solve(&1) |> MapSet.new |> MapSet.size |> IO.inspect(label: "Part 1 Answer"))
  |> then(fn init -> Enum.reduce(Range.new(0, 7), init, fn _, moves ->
    AdventOfCode.solve(moves) |> AdventOfCode.positions_to_moves
  end) end)
  |> AdventOfCode.solve
  |> MapSet.new
  |> MapSet.size
  |> IO.inspect(label: "Part 2 Answer")
else
  _ -> IO.inspect("Failed to read input file")
end
