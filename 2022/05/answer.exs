defmodule AdventOfCode do
  def execute_move(state, {quantity, start, dest}, should_reverse) do
    elms = Enum.take(Enum.at(state, start - 1), quantity) |> then(fn elms -> if should_reverse, do: Enum.reverse(elms), else: elms end)
    List.replace_at(state, start - 1, Enum.drop(Enum.at(state, start - 1), quantity))
    |> List.replace_at(dest - 1, Enum.concat(elms, Enum.at(state, dest - 1)))
  end

  def parse_state(input) do
    Enum.map(input, fn a ->
      String.split(a, ~r/(\ \ \ \ |\]\ \ |\ \ \[|\]\ \[)/) |> Enum.map(&String.replace(&1, ~r/[^A-Z]/, ""))
    end)
    |> Enum.reduce(fn elm, acc ->
      Enum.reduce(Enum.with_index(elm), acc, fn {val, i}, inner_acc ->
        if val != "", do: List.replace_at(inner_acc, i, [val | List.wrap(Enum.at(inner_acc, i))]), else: inner_acc
      end)
    end)
    |> Enum.map(&List.wrap/1)
  end

  def parse_moves([]), do: []
  def parse_moves([a | b]) do
    Regex.scan(~r/\d+/, a)
    |> List.flatten
    |> Enum.map(&String.to_integer/1)
    |> then(&[List.to_tuple(&1) | parse_moves(b)])
  end
end

with {:ok, contents} <- File.read('input.txt') do
  String.split(contents, "\n", trim: true)
  |> Enum.split_while(&!String.starts_with?(&1, "move"))
  |> then(fn {state, moves} ->
    {AdventOfCode.parse_state(tl(Enum.reverse(state))), AdventOfCode.parse_moves(moves)}
  end)
  |> tap(fn {state, moves} ->
    Enum.reduce(moves, state, &AdventOfCode.execute_move(&2, &1, true))
    |> Enum.map_join("", &List.first/1)
    |> IO.inspect(label: "Part 1 Answer")
  end)
  |> then(fn {state, moves} -> Enum.reduce(moves, state, &AdventOfCode.execute_move(&2, &1, false)) end)
  |> Enum.map_join("", &List.first/1)
  |> IO.inspect(label: "Part 2 Answer")
else
  _ -> IO.inspect("Failed to read input file")
end
