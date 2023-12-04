defmodule AdventOfCode do
  defmodule Card do
    @type t :: %__MODULE__{
      id:   integer(),
      wins: MapSet.t(integer()),
      nums: MapSet.t(integer())
    }
    defstruct [:id, :wins, :nums]
  end

  @spec parse(list(String.t())) :: list(Card.t())
  def parse([]), do: []
  def parse([line | rest]) do
    Regex.run(~r/^Card\s+(\d+): (.*) \| (.*)$/, line)
    |> then(fn [_, id, wins, nums | []] ->
      %Card{
        id: String.to_integer(id),
        wins: parse_numbers(wins),
        nums: parse_numbers(nums)
      }
    end)
    |> then(fn x -> [x | parse(rest)] end)
  end

  @spec solve_part_one(list(Card.t())) :: integer()
  def solve_part_one([]), do: 0
  def solve_part_one([%Card{wins: wins, nums: nums} | rest]) do
    MapSet.intersection(wins, nums)
    |> MapSet.size
    |> then(fn x ->
      solve_part_one(rest) + if x > 0, do: :math.pow(2, x - 1) |> round, else: 0
    end)
  end

  @spec solve_part_two(list(Card.t())) :: integer()
  def solve_part_two(cards) do
    expanded_cards = Enum.map(cards, &{&1.id, 1}) |> Enum.into(%{})

    Enum.reduce(cards, expanded_cards, fn %Card{id: id, wins: wins, nums: nums}, acc ->
      total_wins = MapSet.size(MapSet.intersection(wins, nums))
      current_cards = Map.get(acc, id)

      Enum.reduce(Range.new(id + 1, id + total_wins, 1), acc, fn new_id, new_acc ->
        Map.update!(new_acc, new_id, fn x -> x + current_cards end)
      end)
    end)
    |> Map.values
    |> Enum.sum
  end

  @spec parse_numbers(String.t()) :: MapSet.t(integer())
  defp parse_numbers(line) do
    String.split(line, " ", trim: true)
    |> Enum.reject(&"" == &1)
    |> Enum.map(&String.to_integer/1)
    |> MapSet.new
  end
end

with {:ok, contents} <- File.read('input.txt') do
  String.split(contents, "\n", trim: true)
  |> AdventOfCode.parse
  |> tap(fn x ->
    AdventOfCode.solve_part_one(x) |> IO.inspect(label: "Part 1")
  end)
  |> AdventOfCode.solve_part_two
  |> IO.inspect(label: "Part 2")
else
  _ -> IO.inspect("Failed to read input file!")
end
