defmodule AdventOfCode do
  @spec solve_part_one(String.t()) :: Integer.t()
  def solve_part_one(contents) do
    parse_input(contents)
    |> Enum.map(&build_solution/1)
    |> Enum.filter(&(&1 != nil))
    |> Enum.map(fn {a, b} -> (3 * a) + b end)
    |> Enum.sum
  end

  @spec solve_part_two(String.t()) :: Integer.t()
  def solve_part_two(contents) do
    parse_input(contents)
    |> Enum.map(fn {a, b, {t_i, t_j}} -> {a, b, {t_i + 10000000000000, t_j + 10000000000000}} end)
    |> Enum.map(&build_solution/1)
    |> Enum.filter(&(&1 != nil))
    |> Enum.map(fn {a, b} -> (3 * a) + b end)
    |> Enum.sum
  end

  defp parse_input(contents) do
    String.split(contents, "\n\n", trim: true)
    |> Enum.map(fn entry ->
      [a_x, a_y] = Regex.run(~r/Button A: X\+(\d+), Y\+(\d+)/, entry, capture: :all_but_first) |> Enum.map(&String.to_integer/1)
      [b_x, b_y] = Regex.run(~r/Button B: X\+(\d+), Y\+(\d+)/, entry, capture: :all_but_first) |> Enum.map(&String.to_integer/1)
      [t_x, t_y] = Regex.run(~r/Prize: X=(\d+), Y=(\d+)/, entry, capture: :all_but_first) |> Enum.map(&String.to_integer/1)

      {{a_x, a_y}, {b_x, b_y}, {t_x, t_y}}
    end)
  end

  defp build_solution({{a_x, a_y}, {b_x, b_y}, {t_x, t_y}}) do
    b = round(((a_x / a_y) * t_y - t_x) / ((a_x / a_y) * b_y - b_x))
    a = round((t_x - b_x * b) / a_x)

    cond do
      a < 0 || b < 0 -> nil
      (a_x * a + b_x * b) != t_x || (a_y * a + b_y * b) != t_y -> nil
      true -> {a, b}
    end
  end
end


with {:ok, contents} <- File.read("input.txt") do
  AdventOfCode.solve_part_one(contents) |> IO.inspect(label: "Part 1")
  AdventOfCode.solve_part_two(contents) |> IO.inspect(label: "Part 2")
else
  _ -> IO.inspect("Failed to read input file!")
end
