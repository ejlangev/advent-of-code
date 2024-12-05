defmodule AdventOfCode do
  @spec solve_part_one(String.t()) :: Integer.t()
  def solve_part_one(contents) do
    build_sequences(contents)
    |> Enum.map(&(count_xmas_and_samx(&1)))
    |> Enum.sum
  end

  @spec solve_part_two(String.t()) :: Integer.t()
  def solve_part_two(contents) do
    matrix = String.split(contents, "\n", trim: true) |> Enum.map(&String.split(&1, "", trim: true))

    String.split(contents, "\n", trim: true)
    |> Enum.with_index
    |> Enum.map(fn {row, i} ->
      Regex.scan(~r/A/, row, return: :index)
      |> Enum.map(fn [{j, _}] -> {i, j} end)
    end)
    |> List.flatten
    |> Enum.filter(fn {r, c} ->
      r > 0 && r < length(matrix) - 1 && c > 0 && c < length(Enum.at(matrix, 0)) - 1
    end)
    |> Enum.map(&count_x_mas(matrix, &1))
    |> Enum.sum
  end


  defp build_sequences(contents) do
    rows = String.split(contents, "\n", trim: true)
    n_columns = String.length(Enum.at(rows, 0))

    columns = for col <- 0..(n_columns-1) do
      rows |> Enum.map(&String.at(&1, col)) |> Enum.join
    end

    diags = for position <- (length(rows) - 4)..-(n_columns - 4) do
      row = max(position, 0)
      col = if position < 0, do: abs(position), else: 0
      anti_col = if position > 0, do: n_columns - 1, else: n_columns + position - 1
      [{:regular, row, col}, {:anti, row, anti_col}]
    end
    |> List.flatten
    |> Enum.map(fn {type, row, col} ->
      col_diff = if type == :anti, do: -1, else: 1
      Stream.iterate({row, col}, fn {r, c} -> {r + 1, c + col_diff} end)
      |> Stream.take_while(fn {r, c} -> r < length(rows) && c < n_columns && r >= 0 and c >= 0 end)
      |> Enum.map(fn {r, c} -> String.at(Enum.at(rows, r), c) end)
      |> Enum.join
    end)

    rows ++ columns ++ diags
  end

  defp count_xmas_and_samx(source) do
    String.graphemes(source)
    |> Stream.chunk_every(4, 1, :discard)
    |> Stream.map(&Enum.join/1)
    |> Enum.count(&(&1 == "XMAS" || &1 == "SAMX"))
  end

  defp count_x_mas(matrix, {row, col}) do
    upper_left = Enum.at(Enum.at(matrix, row - 1), col - 1)
    upper_right = Enum.at(Enum.at(matrix, row - 1), col + 1)
    lower_left = Enum.at(Enum.at(matrix, row + 1), col - 1)
    lower_right = Enum.at(Enum.at(matrix, row + 1), col + 1)

    case {{upper_left, lower_right}, {upper_right, lower_left}} do
      {{"M", "S"}, {"M", "S"}} -> 1
      {{"M", "S"}, {"S", "M"}} -> 1
      {{"S", "M"}, {"M", "S"}} -> 1
      {{"S", "M"}, {"S", "M"}} -> 1
      _ -> 0
    end
  end
end


with {:ok, contents} <- File.read("input.txt") do
  AdventOfCode.solve_part_one(contents) |> IO.inspect(label: "Part 1")
  AdventOfCode.solve_part_two(contents) |> IO.inspect(label: "Part 2")
else
  _ -> IO.inspect("Failed to read input file!")
end
