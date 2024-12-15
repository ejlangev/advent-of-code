defmodule AdventOfCode do
  @spec solve_part_one(String.t()) :: Integer.t()
  def solve_part_one(contents) do
    {d_i, d_j} = {101, 103}
    parse_input(contents)
    |> run_steps({100, d_i, d_j})
    |> Enum.reject(fn {i, j} -> i == div(d_i, 2) || j == div(d_j, 2) end)
    |> Enum.group_by(fn {i, j} ->
      row_factor = if i > div(d_i, 2), do: 1, else: 0
      col_factor = if j > div(d_j, 2), do: 2, else: 0
      col_factor + row_factor
    end)
    |> Map.values
    |> Enum.map(&Enum.count/1)
    |> Enum.product
  end

  @spec solve_part_two(String.t()) :: Integer.t()
  def solve_part_two(contents) do
    positions = parse_input(contents)

    Enum.find(Range.new(0, 10_000_000), fn i ->
      run_steps(positions, {i, 101, 103}) |> has_continuous_row(28)
    end)
  end

  defp parse_input(contents) do
    String.split(contents, "\n", trim: true)
    |> Enum.map(fn line ->
      [p_i, p_j, v_i, v_j] = Regex.run(~r/p=(\d+),(\d+) v=([-]*\d+),([-]*\d+)/, line, capture: :all_but_first)
      |> Enum.map(&String.to_integer/1)

      {{p_i, p_j}, {v_i, v_j}}
    end)
  end

  defp run_steps(inputs, {steps, d_i, d_j}) do
    Enum.map(inputs, fn {{p_i, p_j}, {v_i, v_j}} -> {rem(p_i + v_i * steps, d_i), rem(p_j + v_j * steps, d_j)} end)
    |> Enum.map(fn {i, j} -> {(if i < 0, do: d_i + i, else: i), (if j < 0, do: d_j + j, else: j)} end)
  end


  defp has_continuous_row(positions, row_size) do
    Enum.group_by(positions, &elem(&1, 0), &elem(&1, 1))
    |> Map.values
    |> Enum.map(fn row ->
      MapSet.new(row)
      |> MapSet.to_list
      |> Enum.sort
      |> Enum.reduce({-1, 0, 0}, fn val, {last, current, max_length} ->
        cond do
          val == (last + 1) -> {val, current + 1, max(max_length, current + 1)}
          true -> {val, 1, max(current, max_length)}
        end
      end)
      |> elem(2)
    end)
    |> Enum.max
    |> then(&(&1 >= row_size))
  end
end


with {:ok, contents} <- File.read("input.txt") do
  AdventOfCode.solve_part_one(contents) |> IO.inspect(label: "Part 1")
  AdventOfCode.solve_part_two(contents) |> IO.inspect(label: "Part 2")
else
  _ -> IO.inspect("Failed to read input file!")
end
