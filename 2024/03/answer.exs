defmodule AdventOfCode do
  @spec solve_part_one(String.t()) :: Integer.t()
  def solve_part_one(contents) do
    build_mul_values(contents)
    |> Enum.map(fn {l, r, _} -> l * r end)
    |> Enum.sum
    # Regex.scan(~r/mul\((\d{1,3}),(\d{1,3})\)/, contents, capture: :all_but_first)
    # |> Enum.map(fn [a, b] ->
    #   String.to_integer(a) * String.to_integer(b)
    # end)
    # |> Enum.sum
  end

  @spec solve_part_two(String.t()) :: Integer.t()
  def solve_part_two(contents) do
    allowed_ranges = build_allowed_ranges(contents)

    build_mul_values(contents)
    |> Enum.filter(fn {_, _, index} ->
      Enum.any?(allowed_ranges, &(index in &1))
    end)
    |> Enum.map(fn {l, r, _} -> l * r end)
    |> Enum.sum
  end

  defp build_mul_values(contents) do
    Regex.scan(~r/mul\((\d{1,3}),(\d{1,3})\)/, contents, return: :index, capture: :all_but_first)
    |> Enum.map(fn [{l_index, l_len}, {r_index, r_len}] ->
      {String.to_integer(String.slice(contents, l_index, l_len)), String.to_integer(String.slice(contents, r_index, r_len)), r_index}
    end)
  end

  defp build_allowed_ranges(contents) do
    Regex.scan(~r/(do\(\)|don't\(\))/, contents, return: :index, capture: :first)
    |> Enum.map(fn [{index, length}] ->
      {String.slice(contents, index, length), index}
    end)
    |> then(&([ {"do()", 0} | &1] ++ [{"don't()", String.length(contents)}]))
    |> Enum.reduce({[], 0}, fn
      {"do()", index}, {acc, -1} -> {acc, index}
      {"do()", _}, acc -> acc
      {"don't()", _}, {acc, -1} -> {acc, -1}
      {"don't()", index}, {acc, last} -> {[Range.new(last, index) | acc], -1}
    end)
    |> elem(0)
  end
end


with {:ok, contents} <- File.read('input.txt') do
  AdventOfCode.solve_part_one(contents) |> IO.inspect(label: "Part 1")
  AdventOfCode.solve_part_two(contents) |> IO.inspect(label: "Part 2")
else
  _ -> IO.inspect("Failed to read input file!")
end
