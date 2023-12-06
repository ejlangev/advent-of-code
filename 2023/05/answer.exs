defmodule AdventOfCode do
  defmodule Converter do
    @type t :: %__MODULE__{
      from: String.t(),
      to: String.t(),
      ranges: list({Range.t(), integer()})
    }

    defstruct [:from, :to, :ranges]
  end

  @spec parse(String.t()) :: {list(integer()), list(Converter.t())}
  def parse(contents) do
    [raw_seeds | raw_maps] = String.split(contents, "\n\n", trim: true)

    seeds = Regex.scan(~r/(\d+)/, raw_seeds)
    |> Enum.map(&List.first/1)
    |> Enum.map(&String.to_integer/1)

    maps = Enum.map(raw_maps, fn raw_map ->
      [mapping | ranges] = String.split(raw_map, "\n", trim: true)

      [_, from, to | []] = Regex.run(~r/([a-z]+)-to-([a-z]+)/, mapping)

      ranges = Enum.map(ranges, fn r -> String.split(r, " ", trim: true) |> Enum.map(&String.to_integer/1) end)
      |> Enum.map(fn [dest, source, range | []] ->
        {Range.new(source, source + range - 1), dest - source}
      end)

      %Converter{
        from: from,
        to: to,
        ranges: ranges
      }
    end)

    {seeds, maps}
  end

  @spec solve_part_one({list(integer()), list(Converter.t())}) :: integer()
  def solve_part_one({seeds, maps}) do
    from_map = Enum.map(maps, &{&1.from, &1}) |> Enum.into(%{})

    Stream.unfold({"seed", seeds}, fn
      nil -> nil
      {"location", values} -> {{"location", values}, nil}
      {source, values} ->
        converter = Map.fetch!(from_map, source)
        Enum.map(values, fn val ->
          Enum.reduce(converter.ranges, val, fn {range, adjustment}, acc ->
            if val in range, do: val + adjustment, else: acc
          end)
        end)
        |> then(fn new_vals -> {{source, values}, {converter.to, new_vals}} end)
    end)
    |> Enum.at(-1)
    |> then(&Enum.min(elem(&1, 1)))
  end

  def solve_part_two({ seeds, maps }) do
    from_map = Enum.map(maps, &{&1.from, &1}) |> Enum.into(%{})
    initial_ranges = Enum.chunk_every(seeds, 2)
    |> Enum.map(fn [start, range | []] -> Range.new(start, start + range - 1) end)

    Stream.unfold({"seed", initial_ranges}, fn
      nil -> nil
      {"location", values} -> {{"location", values}, nil}
      {source, ranges} ->
        converter = Map.fetch!(from_map, source)
        converter_raw_ranges = Enum.map(converter.ranges, &elem(&1, 0))

        Enum.flat_map(ranges, fn range ->
          # Output: range - all converter ranges as a passthrough
          non_impacted_ranges = range_differences(range, converter_raw_ranges)

          Enum.reject(converter.ranges, &Range.disjoint?(range, elem(&1, 0)))
          |> Enum.map(fn {converter_range, shifter} ->
            Range.shift(overlapping_range(converter_range, range), shifter)
          end)
          |> then(fn x -> x ++ non_impacted_ranges end)
        end)
        |> then(fn new_vals -> {{source, ranges}, {converter.to, new_vals}} end)
    end)
    |> Enum.at(-1)
    |> elem(1)
    |> Enum.map(&Enum.min/1)
    |> Enum.min
  end

  defp range_differences(left, rights) do
    Enum.reduce(rights, [left], fn right, acc ->
      Enum.flat_map(acc, fn inner_left ->
        range_difference(inner_left, right)
      end)
    end)
  end

  defp overlapping_range(rng1, rng2) do
    {min1, max1} = Enum.min_max(rng1)
    {min2, max2} = Enum.min_max(rng2)

    new_start = Enum.max([min1, min2])
    new_end = Enum.min([max1, max2])
    Range.new(new_start, new_end)
  end

  defp range_difference(rng1, rng2) do
    {min1, max1} = Enum.min_max(rng1)
    {min2, max2} = Enum.min_max(rng2)

    cond do
      min2 > max1 or max2 < min1 ->
        [rng1]
      min2 <= min1 and max2 >= max1 ->
        []
      min2 > min1 and max2 < max1 ->
        [min1..(min2-1), (max2+1)..max1]
      min2 <= min1 ->
        [(max2+1)..max1]
      true ->
        [min1..(min2-1)]
    end
  end
end

with {:ok, contents} <- File.read('input.txt') do
  AdventOfCode.parse(contents)
  |> tap(fn x ->
    AdventOfCode.solve_part_one(x) |> IO.inspect(label: "Part 1")
  end)
  |> AdventOfCode.solve_part_two
  |> IO.inspect(label: "Part 2")
else
  _ -> IO.inspect("Failed to read input file!")
end
