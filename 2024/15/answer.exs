defmodule AdventOfCode do
  @directions %{
    :up => {-1, 0},
    :down => {1, 0},
    :left => {0, -1},
    :right => {0, 1}
  }

  @spec solve_part_one(String.t()) :: Integer.t()
  def solve_part_one(contents) do
    {walls, start_boxes, start_robot, moves} = parse_input(contents)

    Enum.reduce(moves, {start_boxes, start_robot}, fn move, {boxes, {r_i, r_j}} ->
      {d_i, d_j} = Map.fetch!(@directions, move)
      new_position = {r_i + d_i, r_j + d_j}

      {successful, updated_boxes, new_boxes} = push_boxes({walls, boxes, new_position, move})

      {
        MapSet.union(MapSet.difference(boxes, updated_boxes), new_boxes),
        (if successful, do: new_position, else: {r_i, r_j})
      }
    end)
    |> elem(0)
    |> Enum.map(fn {i, j} -> 100 * i + j end)
    |> Enum.sum
  end

  @spec solve_part_two(String.t()) :: Integer.t()
  def solve_part_two(contents) do
    {walls, start_boxes, start_robot, moves} = parse_part_two(contents)

    Enum.reduce(moves, {start_boxes, start_robot}, fn move, {boxes, {r_i, r_j}} ->
      {d_i, d_j} = Map.fetch!(@directions, move)
      new_position = {r_i + d_i, r_j + d_j}

      {successful, updated_boxes, new_boxes} = push_wide_boxes({walls, boxes, new_position, move})

      {
        MapSet.union(MapSet.difference(boxes, updated_boxes), new_boxes),
        (if successful, do: new_position, else: {r_i, r_j})
      }
    end)
    |> elem(0)
    |> Enum.map(fn {i, j, p} -> (if p == :l, do: 100 * i + j, else: 0) end)
    |> Enum.sum
  end

  defp parse_input(contents) do
    String.split(contents, "\n\n", trim: true)
    |> Enum.map(&String.trim/1)
    |> then(fn [board, moves] ->
      String.split(board, "\n", trim: true)
      |> Enum.with_index
      |> Enum.reduce({[], [], nil}, fn {line, i}, outer_acc ->
        String.split(line, "", trim: true)
        |> Enum.with_index
        |> Enum.reduce(outer_acc, fn {val, j}, {walls, boxes, robot} ->
          case val do
            "#" -> {[{i, j} | walls], boxes, robot}
            "O" -> {walls, [{i, j} | boxes], robot}
            "@" -> {walls, boxes, {i, j}}
            "." -> {walls, boxes, robot}
          end
        end)
      end)
      |> then(fn {walls, boxes, robot} ->
        {MapSet.new(walls), MapSet.new(boxes), robot, parse_moves(moves)} end)
    end)
  end

  defp parse_part_two(contents) do
    String.split(contents, "\n\n", trim: true)
    |> Enum.map(&String.trim/1)
    |> then(fn [board, moves] ->
      String.replace(board, ["#", "O", "@", "."], fn
        "#" -> "##"
        "O" -> "OO"
        "@" -> "@."
        "." -> ".."
      end)
      |> String.split("\n", trim: true)
      |> Enum.with_index
      |> Enum.reduce({[], [], nil}, fn {line, i}, outer_acc ->
        String.split(line, "", trim: true)
        |> Enum.with_index
        |> Enum.reduce(outer_acc, fn {val, j}, {walls, boxes, robot} ->
          case val do
            "#" -> {[{i, j} | walls], boxes, robot}
            "O" -> {walls, [{i, j, (if rem(j, 2) == 0, do: :l, else: :r)} | boxes], robot}
            "@" -> {walls, boxes, {i, j}}
            "." -> {walls, boxes, robot}
          end
        end)
      end)
      |> then(fn {walls, boxes, robot} ->
        {MapSet.new(walls), MapSet.new(boxes), robot, parse_moves(moves)} end)
    end)
  end

  defp parse_moves(moves) do
    String.split(moves, "\n", trim: true)
    |> Enum.join
    |> String.split("", trim: true)
    |> Enum.map(fn
      "<" -> :left
      "^" -> :up
      ">" -> :right
      "v" -> :down
    end)
  end

  defp push_boxes({walls, boxes, {r_i, r_j}, move}) do
    {d_i, d_j} = Map.fetch!(@directions, move)

    Stream.unfold({r_i, r_j}, fn
      nil -> nil
      {c_i, c_j} ->
        cond do
          MapSet.member?(walls, {c_i, c_j}) -> {nil, nil}
          MapSet.member?(boxes, {c_i, c_j}) -> {{c_i, c_j}, {c_i + d_i, c_j + d_j}}
          true -> nil
        end
    end)
    |> Enum.to_list
    |> then(fn results ->
      cond do
        Enum.count(results) == 0 -> {true, MapSet.new, MapSet.new}
        List.last(results) == nil -> {false, MapSet.new, MapSet.new}
        true -> {true, MapSet.new(results), MapSet.new(results |> Enum.map(fn {i, j} -> {i + d_i, j + d_j} end))}
      end
    end)
  end

  defp push_wide_boxes({walls, boxes, {r_i, r_j}, move}) when move == :left or move == :right do
    {d_i, d_j} = Map.fetch!(@directions, move)

    Stream.unfold({r_i, r_j}, fn
      nil -> nil
      {c_i, c_j} ->
        cond do
          MapSet.member?(walls, {c_i, c_j}) -> {nil, nil}
          MapSet.member?(boxes, {c_i, c_j, :l})  -> {{c_i, c_j, :l}, {c_i + d_i, c_j + d_j}}
          MapSet.member?(boxes, {c_i, c_j, :r})  -> {{c_i, c_j, :r}, {c_i + d_i, c_j + d_j}}
          true -> nil
        end
    end)
    |> Enum.to_list
    |> then(fn results ->
      cond do
        Enum.count(results) == 0 -> {true, MapSet.new, MapSet.new}
        List.last(results) == nil -> {false, MapSet.new, MapSet.new}
        true -> {true, MapSet.new(results), MapSet.new(results |> Enum.map(fn {i, j, p} -> {i + d_i, j + d_j, p} end))}
      end
    end)
  end

  defp push_wide_boxes({walls, boxes, {r_i, r_j}, move}) do
    {d_i, d_j} = Map.fetch!(@directions, move)
    Stream.unfold({r_i, MapSet.new([r_j])}, fn
      nil -> nil
      {c_i, cols} ->
        results = Enum.reduce(cols, MapSet.new, fn c_j, acc ->
          cond do
            acc == nil -> nil
            MapSet.member?(walls, {c_i, c_j}) -> nil
            MapSet.member?(boxes, {c_i, c_j, :l}) ->
              MapSet.union(acc, MapSet.new([{c_i, c_j, :l}, {c_i, c_j + 1, :r}]))
            MapSet.member?(boxes, {c_i, c_j, :r}) ->
              MapSet.union(acc, MapSet.new([{c_i, c_j - 1, :l}, {c_i, c_j, :r}]))
            true -> acc
          end
        end)

        cond do
          results == nil -> {nil, nil}
          MapSet.size(results) == 0 -> nil
          true -> {results, {c_i + d_i, Enum.map(results, &elem(&1, 1)) |> MapSet.new}}
        end
    end)
    |> Enum.to_list
    |> then(fn results ->
      cond do
        Enum.count(results) == 0 -> {true, MapSet.new, MapSet.new}
        List.last(results) == nil -> {false, MapSet.new, MapSet.new}
        true ->
          Enum.reduce(results, MapSet.new, &MapSet.union/2)
          |> then(&{true, &1, MapSet.new(Enum.map(&1, fn {i, j, p} -> {i + d_i, j + d_j, p} end))})
      end
    end)
  end
end


with {:ok, contents} <- File.read("input.txt") do
  AdventOfCode.solve_part_one(contents) |> IO.inspect(label: "Part 1")
  AdventOfCode.solve_part_two(contents) |> IO.inspect(label: "Part 2")
else
  _ -> IO.inspect("Failed to read input file!")
end
