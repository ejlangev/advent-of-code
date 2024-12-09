defmodule AdventOfCode do
  @directions %{
    :north => {-1, 0},
    :south => {1, 0},
    :west => {0, -1},
    :east => {0, 1}
  }

  @rotations %{
    :north => :east,
    :south => :west,
    :west => :north,
    :east => :south
  }

  @spec solve_part_one(String.t()) :: Integer.t()
  def solve_part_one(contents) do
    {position, map} = parse_input(contents)

    get_occupied_positions_and_directions(position, map)
    |> Enum.map(&{elem(&1, 0), elem(&1, 1)})
    |> MapSet.new
    |> Enum.count
  end

  @spec solve_part_two(String.t()) :: Integer.t()
  def solve_part_two(contents) do
    {position, map} = parse_input(contents)

    get_occupied_positions_and_directions(position, map)
    |> Enum.map(fn {i, j, direction} ->
      {d_i, d_j} = Map.fetch!(@directions, direction)
      {new_i, new_j} = {i + d_i, j + d_j}

      if new_i < 0 or new_i >= length(map) or new_j < 0 or new_j > length(Enum.at(map, 0)) do
        nil
      else
        {new_i, new_j}
      end
    end)
    |> Enum.filter(&is_tuple/1)
    |> Enum.filter(fn {new_i, new_j} ->
      new_map = List.replace_at(map, new_i, List.replace_at(Enum.at(map, new_i), new_j, "#"))
      is_infinite_loop(position, new_map)
    end)
    |> MapSet.new
    |> Enum.count
  end

  defp parse_input(contents) do
    map = String.split(contents, "\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))

    starting_position = Enum.with_index(map)
    |> Enum.find_value(fn {row, i} ->
      Enum.with_index(row)
      |> Enum.find_value(fn {val, j} ->
        if val == "^", do: {i, j, :north}
      end)
    end)

    {starting_position, map}
  end

  defp get_occupied_positions_and_directions(position, map) do
    n_rows = length(map)
    n_cols = length(Enum.at(map, 0))
    row_range = Range.new(0, n_rows - 1)
    col_range = Range.new(0, n_cols - 1)

    Stream.unfold(position, fn
      nil -> nil
      {i, j, direction} ->
        {d_i, d_j} = Map.fetch!(@directions, direction)
        {new_i, new_j} = {i + d_i, j + d_j}

        cond do
          new_i in row_range and new_j in col_range ->
            new_value = Enum.at(Enum.at(map, new_i), new_j)

            if new_value == "#" do
              {{i, j, direction}, {i, j, Map.fetch!(@rotations, direction)}}
            else
              {{i, j, direction}, {new_i, new_j, direction}}
            end
          true -> {{i, j, direction}, nil}
        end
    end)
    |> Enum.to_list
  end

  defp is_infinite_loop({i, j, direction}, map) do
    n_rows = length(map)
    n_cols = length(Enum.at(map, 0))
    row_range = Range.new(0, n_rows - 1)
    col_range = Range.new(0, n_cols - 1)

    Stream.unfold({{i, j, direction}, MapSet.new}, fn
      nil -> nil
      {{i, j, direction}, used} ->
        {d_i, d_j} = Map.fetch!(@directions, direction)
        {new_i, new_j} = {i + d_i, j + d_j}

        cond do
          new_i in row_range and new_j in col_range ->
            new_value = Enum.at(Enum.at(map, new_i), new_j)

            new_position = if new_value == "#", do: {i, j, Map.fetch!(@rotations, direction)}, else: {new_i, new_j, direction}

            if MapSet.member?(used, new_position) do
              {true, nil}
            else
              {false, {new_position, MapSet.put(used, {i, j, direction})}}
            end
          true -> {false, nil}
        end
    end)
    |> Enum.to_list
    |> List.last
  end
end


with {:ok, contents} <- File.read("input.txt") do
  AdventOfCode.solve_part_one(contents) |> IO.inspect(label: "Part 1")
  AdventOfCode.solve_part_two(contents) |> IO.inspect(label: "Part 2")
else
  _ -> IO.inspect("Failed to read input file!")
end
