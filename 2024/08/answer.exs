defmodule AdventOfCode do
  @spec solve_part_one(String.t()) :: Integer.t()
  def solve_part_one(contents) do
    parse_input(contents)
    |> then(fn {{max_i, max_j}, entries} ->
      Enum.flat_map(entries, &build_pairs(elem(&1, 1)))
      |> Enum.flat_map(&find_antinodes/1)
      |> Enum.filter(fn {i, j} -> i >= 0 && i < max_i && j >= 0 && j < max_j end)
    end)
    |> MapSet.new
    |> MapSet.size
  end

  @spec solve_part_two(String.t()) :: Integer.t()
  def solve_part_two(contents) do
    parse_input(contents)
    |> then(fn {{max_i, max_j}, entries} ->
      equations = Enum.flat_map(entries, fn {k ,v} ->
        build_pairs(v) |> Enum.map(&{k, &1})
      end)
      |> Enum.map(fn {k, v} -> {k, build_equation(v)} end)

      for i <- Range.new(0, max_i - 1), j <- Range.new(0, max_j - 1) do
        build_matching_lines({i, j}, equations)
      end
    end)
    |> List.flatten
    |> Enum.map(&elem(&1, 1))
    |> MapSet.new
    |> MapSet.size
  end

  defp parse_input(contents) do
    lines = String.split(contents, "\n", trim: true)

    lines
    |> Enum.with_index
    |> Enum.reduce(Map.new, fn {line, i}, acc ->
      String.split(line, "", trim: true)
      |> Enum.with_index
      |> Enum.reduce(acc, fn {char, j}, inner_acc ->
        case char do
          "." -> inner_acc
          _ -> Map.put(inner_acc, char, [{i, j} | Map.get(inner_acc, char, [])])
        end
      end)
    end)
    |> then(&{{length(lines), String.length(Enum.at(lines, 0))}, &1})
  end

  defp build_pairs(elm) when length(elm) <= 1 do [] end
  defp build_pairs([a | rest]) do
    Enum.map(rest, &[a, &1]) ++ build_pairs(rest)
  end

  defp find_antinodes([{i1, j1}, {i2, j2}]) do
    i_diff = i2 - i1
    j_diff = j2 - j1
    [{i1 - i_diff, j1 - j_diff}, {i2 + i_diff, j2 + j_diff}]
  end

  defp build_equation([{i1, j1}, {i2, j2}]) do
    {{i2 - i1, j2 - j1}, {i1, j1}}
  end

  defp build_matching_lines({i, j}, lines) do
    Enum.filter(lines, fn {_, {{s_n, s_d}, {p_i, p_j}}} ->
      i == (s_n * (j - p_j) / s_d + p_i)
    end)
    |> Enum.map(fn {label, _} -> {label, {i, j}} end)
  end
end


with {:ok, contents} <- File.read("input.txt") do
  AdventOfCode.solve_part_one(contents) |> IO.inspect(label: "Part 1")
  AdventOfCode.solve_part_two(contents) |> IO.inspect(label: "Part 2")
else
  _ -> IO.inspect("Failed to read input file!")
end
