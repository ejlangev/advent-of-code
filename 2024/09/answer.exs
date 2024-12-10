defmodule AdventOfCode do
  @spec solve_part_one(String.t()) :: Integer.t()
  def solve_part_one(contents) do
    parse_input(contents)
    |> compact_blocks
    |> Enum.with_index
    |> Enum.reduce(0, fn {val, i}, acc -> acc + val * i end)
  end

  @spec solve_part_two(String.t()) :: Integer.t()
  def solve_part_two(contents) do
    parse_input(contents)
    |> compact_files
    |> Enum.with_index
    |> Enum.reduce(0, fn {val, i}, acc -> acc + val * i end)
  end

  defp parse_input(contents) do
    String.trim(contents)
    |> String.split("", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.reduce({:block, 0, 0, []}, fn entry, {next_type, next_index, free_count, vals} ->
      case next_type do
        :block -> {:free, next_index + 1, free_count, [{:block, next_index, entry} | vals]}
        :free -> {:block, next_index, free_count + entry, [{:free, free_count, entry} | vals]}
      end
    end)
    |> elem(3)
    |> Enum.reverse
  end

  defp compact_blocks(entries) do
    split_index = Enum.reverse(entries)
    |> Enum.with_index
    |> Enum.reduce({0, nil}, fn
      _, {nil, index} -> {nil, index}
      {{:free, free_count, _}, index}, {total, i} ->
        if free_count < total do
          {nil, index}
        else
          {total, i}
        end
      {{:block, _, val}, _}, {total, _} ->
        {total + val, -1}
      end)
      |> elem(1)
      |> then(&(length(entries) - &1 - 1))


      to_compact = Enum.slice(entries, split_index, length(entries))
      |> Enum.reverse
      |> Enum.filter(fn {type, _, _} -> type == :block end)
      |> Enum.flat_map(fn {_, index, count} -> List.duplicate(index, count) end)

      Enum.slice(entries, 0, split_index)
      |> Enum.reduce({[], to_compact}, fn
        {:block, index, count}, {acc, remaining} ->
          {acc ++ List.duplicate(index, count), remaining}
        {:free, _, size}, {acc, remaining} ->
          {acc ++ Enum.take(remaining, size), Enum.drop(remaining, size)}
      end)
      |> then(&elem(&1, 0) ++ elem(&1, 1))
  end

  defp compact_files(entries) do
    destinations = Enum.with_index(entries)
    |> Enum.filter(fn {{type, _, _}, _} -> type == :free end)
    |> Enum.map(fn {{_, _, size}, index} -> {size, index} end)

    moves = Enum.with_index(entries)
    |> Enum.reverse
    |> Enum.reduce({destinations, []}, fn
      {{:free, _, _}, index}, acc -> acc
      {{:block, id, size}, index}, {destinations, acc} ->
        destination_index = Enum.find_index(destinations, fn {d_size, d_index} ->
          d_index < index && d_size >= size
        end)

        if destination_index == nil do
          {destinations, acc}
        else
          {d_size, d_index} = Enum.at(destinations, destination_index)
          {List.replace_at(destinations, destination_index, {d_size - size, d_index}), [{index, d_index} | acc]}
        end
    end)
    |> then(&elem(&1, 1))
    |> Enum.reverse
    |> Enum.group_by(&elem(&1, 1), &elem(&1, 0))

    all_impacted = Map.values(moves) |> List.flatten |> MapSet.new

    Enum.with_index(entries)
    |> Enum.reduce([], fn
      {{:block, id, size}, index}, acc ->
        if MapSet.member?(all_impacted, index) do
          acc ++ List.duplicate(0, size)
        else
          acc ++ List.duplicate(id, size)
        end
      {{:free, _, size}, index}, acc ->
        if Map.has_key?(moves, index) do
          filler = Map.fetch!(moves, index)
          |> Enum.map(&Enum.at(entries, &1))
          |> Enum.flat_map(fn {_, id, size} ->
            List.duplicate(id, size)
          end)

          acc ++ filler ++ List.duplicate(0, size - length(filler))
        else
          acc ++ List.duplicate(0, size)
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
