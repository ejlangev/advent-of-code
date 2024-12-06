defmodule AdventOfCode do
  @spec solve_part_one(String.t()) :: Integer.t()
  def solve_part_one(contents) do
    parse_input(contents)
    |> then(&partition_updates/1)
    |> elem(0)
    |> Enum.map(&Enum.at(&1, floor(length(&1) / 2)))
    |> Enum.sum
  end

  @spec solve_part_two(String.t()) :: Integer.t()
  def solve_part_two(contents) do
    {rules, updates} = parse_input(contents)

    {_, invalid_updates} = partition_updates({rules, updates})

    Enum.map(invalid_updates, &find_valid_ordering(rules, &1, []))
    |> Enum.map(&Enum.at(&1, floor(length(&1) / 2)))
    |> Enum.sum
  end

  defp parse_input(contents) do
    String.split(contents, "\n\n", trim: true)
    |> then(fn [rules, updates] ->
      parsed_rules = String.split(rules, "\n", trim: true)
      |> Enum.map(&String.split(&1, "|", trim: true))
      |> Enum.map(fn [l, r] -> {String.to_integer(l), String.to_integer(r)} end)
      |> Enum.reduce(Map.new, fn {l, r}, acc ->
        Map.put(acc, l, MapSet.put(Map.get(acc, l, MapSet.new), r))
      end)

      parsed_updates = String.split(updates, "\n", trim: true)
      |> Enum.map(fn line ->
        String.split(line, ",", trim: true) |> Enum.map(&String.to_integer/1)
      end)

      {parsed_rules, parsed_updates}
    end)
  end

  defp partition_updates({rules, updates}) do
    Enum.group_by(updates, &is_valid_update(rules, &1))
    |> then(fn v -> {Map.fetch!(v, true), Map.fetch!(v, false)} end)
  end

  defp is_valid_update(_, []) do true end
  defp is_valid_update(rules, [elm | remainder]) do
    MapSet.subset?(MapSet.new(remainder), Map.get(rules, elm, MapSet.new))
      and is_valid_update(rules, remainder)
  end


  defp find_valid_ordering(_, [], acc) do Enum.reverse(acc) end
  defp find_valid_ordering(rules, update, acc) do
    all_values_set = MapSet.new(update)
    next_val = Enum.find(update, fn v ->
      other_values_set = MapSet.delete(all_values_set, v)
      MapSet.subset?(other_values_set, Map.get(rules, v, MapSet.new))
    end)

    find_valid_ordering(rules, MapSet.to_list(MapSet.delete(all_values_set, next_val)), [next_val | acc])
  end
end


with {:ok, contents} <- File.read("input.txt") do
  AdventOfCode.solve_part_one(contents) |> IO.inspect(label: "Part 1")
  AdventOfCode.solve_part_two(contents) |> IO.inspect(label: "Part 2")
else
  _ -> IO.inspect("Failed to read input file!")
end
