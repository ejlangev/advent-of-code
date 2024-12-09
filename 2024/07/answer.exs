defmodule AdventOfCode do
  @spec solve_part_one(String.t()) :: Integer.t()
  def solve_part_one(contents) do
    parse_input(contents)
    |> Enum.filter(&is_solvable(&1, ["*", "+"]))
    |> Enum.map(&elem(&1, 0))
    |> List.flatten
    |> Enum.sum
  end

  @spec solve_part_two(String.t()) :: Integer.t()
  def solve_part_two(contents) do
    parse_input(contents)
    |> Enum.filter(&is_solvable(&1, ["*", "+", "||"]))
    |> Enum.map(&elem(&1, 0))
    |> List.flatten
    |> Enum.sum
  end

  defp parse_input(contents) do
    String.split(contents, "\n", trim: true)
    |> Enum.map(fn line ->
      String.split(line, ":", trim: true)
      |> then(fn [target, values] ->
        String.split(values, " ", trim: true)
        |> Enum.map(&String.to_integer/1)
        |> then(&({String.to_integer(target), &1}))
      end)
    end)
  end

  defp is_solvable({target, [a, b]}, operators) do
    Enum.any?(operators, fn operator ->
      case operator do
        "*" -> a * b == target
        "+" -> a + b == target
        "||" -> String.to_integer("#{a}#{b}") == target
      end
    end)
  end
  defp is_solvable({target, [a, b | rest]}, operators) do
    Enum.any?(operators, fn operator ->
      case operator do
        "*" -> is_solvable({target, [a * b | rest]}, operators)
        "+" -> is_solvable({target, [a + b | rest]}, operators)
        "||" -> is_solvable({target, [String.to_integer("#{a}#{b}") | rest]}, operators)
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
