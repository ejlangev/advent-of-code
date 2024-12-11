defmodule AdventOfCode do
  @spec solve_part_one(String.t()) :: Integer.t()
  def solve_part_one(contents) do
    parse_input(contents) |> apply_blinks(25)
  end

  @spec solve_part_two(String.t()) :: Integer.t()
  def solve_part_two(contents) do
    parse_input(contents) |> apply_blinks(75)
  end


  defp parse_input(contents) do
    String.trim(contents)
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp apply_blinks(entries, count) do
    apply_blinks(entries, count, Map.new) |> elem(0)
  end
  defp apply_blinks(entries, 0, memo) do {length(entries), memo} end
  defp apply_blinks(entries, count, m) do
    if Map.has_key?(m, {entries, count}) do
      {Map.fetch!(m, {entries, count}), m}
    else
      Enum.reduce(entries, {0, m}, fn val, {acc, memo} ->
        cond do
          Map.has_key?(memo, {val, count}) -> {acc + Map.fetch!(memo, {val, count}), memo}
          true ->
            {result, new_memo} = apply_blinks(blink_step(val), count - 1, memo)
            {acc + result, Map.put(new_memo, {val, count}, result)}
        end
      end)
      |> then(fn {result, memo} ->
        {result, Map.put(memo, {entries, count}, result)}
      end)
    end
  end

  defp blink_step(0) do [1] end
  defp blink_step(n) do
    if rem(String.length(Integer.to_string(n)), 2) == 0 do
      s = Integer.to_string(n)
      {left, right} = String.split_at(s, floor(String.length(s) / 2))
      [String.to_integer(left), String.to_integer(right)]
    else
      [n * 2024]
    end
  end
end


with {:ok, contents} <- File.read("input.txt") do
  AdventOfCode.solve_part_one(contents) |> IO.inspect(label: "Part 1")
  AdventOfCode.solve_part_two(contents) |> IO.inspect(label: "Part 2")
else
  _ -> IO.inspect("Failed to read input file!")
end
