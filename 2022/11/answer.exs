defmodule AdventOfCode do
  def simulate_rounds(monkeys, 0, _), do: monkeys
  def simulate_rounds(input, rounds, divide) do
    Enum.reduce(Range.new(0, Enum.count(input) - 1), input, fn i, monkeys ->
      mod = Enum.map(input, &Map.get(elem(&1, 1), "divisor")) |> Enum.product
      monkey = Map.get(monkeys, i)
      item_count = Enum.count(Map.get(monkey, "items"))

      Enum.reduce(Map.get(monkey, "items"), monkeys, fn item, acc ->
        {bumped_worry, _} = Code.eval_string(Map.get(monkey, "operation"), [old: item])
        reduced_worry = div(bumped_worry, (if divide, do: 3, else: 1))
        new_worry = rem(reduced_worry, mod)

        target_index = if rem(new_worry, Map.get(monkey, "divisor")) == 0, do: Map.get(monkey, "true_target"), else: Map.get(monkey, "false_target")
        target_monkey = Map.get(acc, target_index)

        Map.put(acc, target_index, Map.put(
          target_monkey, "items", Map.get(target_monkey, "items") ++ [new_worry]
        ))
      end)
      |> Map.put(i, Map.merge(monkey, %{
        "items" => [], "inspected" => Map.get(monkey, "inspected") + item_count
      }))
    end)
    |> simulate_rounds(rounds - 1, divide)
  end

  def parse_monkeys(lst), do: parse_monkeys(Enum.with_index(lst), Map.new)
  def parse_monkeys([], accum), do: accum
  def parse_monkeys([{hd, i} | rest], accum) do
    String.split(hd, "\n", trim: true)
    |> Enum.reduce(%{"inspected" => 0}, fn line, map ->
      case String.trim(line) do
        "Monkey " <> _ -> map
        "Starting items: " <> items -> Map.put(map, "items", String.split(items, ",", trim: true) |> Enum.map(&String.trim/1) |> Enum.map(&String.to_integer/1))
        "Operation: new = " <> op -> Map.put(map, "operation", op)
        "Test: divisible by " <> num -> Map.put(map, "divisor", String.to_integer(num))
        "If true: throw to monkey " <> num -> Map.put(map, "true_target", String.to_integer(num))
        "If false: throw to monkey " <> num -> Map.put(map, "false_target", String.to_integer(num))
      end
    end)
    |> then(&parse_monkeys(rest, Map.put(accum, i, &1)))
  end
end

with {:ok, contents} <- File.read('input.txt') do
  String.split(contents, "\n\n", trim: true)
  |> AdventOfCode.parse_monkeys
  |> tap(fn res ->
    AdventOfCode.simulate_rounds(res, 20, true)
    |> Enum.map(&Map.get(elem(&1, 1), "inspected"))
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.product
    |> IO.inspect(label: "Part 1 Answer")
  end)
  |> AdventOfCode.simulate_rounds(10000, false)
  |> Enum.map(&Map.get(elem(&1, 1), "inspected"))
  |> Enum.sort(:desc)
  |> Enum.take(2)
  |> Enum.product
  |> IO.inspect(label: "Part 2 Answer")
else
  _ -> IO.inspect("Failed to read input file")
end
