defmodule AdventOfCode do
  defmodule Game do
    @type t :: %__MODULE__{
      id:   integer(),
      moves: list(list(Move.t()))
    }
    @enforce_keys [:id, :moves]
    defstruct [:id, :moves]
  end

  defmodule Move do
    @type t :: %__MODULE__{
      color: String.t(),
      amount: integer()
    }
    defstruct [:color, :amount]
  end

  @spec parse(list(String.t())) :: list(Game.t())
  def parse([]), do: []
  def parse([a | b]) do
    [parse_game(a) | parse(b)]
  end

  @spec check(list(Game.t()), %{String.t() => integer()}) :: list(Game.t())
  def check([], _), do: []
  def check([%Game{moves: moves} = game | tl], limits) do
    is_valid = Enum.all?(moves, fn comps ->
      Enum.all?(comps, fn %Move{ color: color, amount: amount } ->
        Map.fetch!(limits, color) >= amount
      end)
    end)

    if is_valid, do: [game | check(tl, limits)], else: check(tl, limits)
  end

  @spec sum_ids(list(Game.t())) :: integer()
  def sum_ids([]), do: 0
  def sum_ids([%Game{id: id} | tl]) do
    id + sum_ids(tl)
  end

  @spec compute_power(list(Game.t())) :: integer()
  def compute_power([]), do: 0
  def compute_power([%Game{moves: moves} | tl]) do
    Enum.reduce(moves, %{}, fn comps, acc ->
      Enum.reduce(comps, acc, fn %Move{color: color, amount: amount}, inner_acc ->
        Map.update(inner_acc, color, amount, fn existing ->
          Enum.max([existing, amount])
        end)
      end)
    end)
    |> Map.values
    |> Enum.product
    |> then(fn x -> x + compute_power(tl) end)
  end

  @spec parse_game(String.t()) :: Game.t()
  defp parse_game(s) do
    Regex.run(~r/Game (\d+): (.*)/, s)
    |> then(fn [_ , id , rest | []] ->
      String.split(rest, ";", trim: true)
      |> Enum.map(&Regex.scan(~r/(\d+) ([a-z]+)/, &1))
      |> Enum.map(fn elm ->
        Enum.map(elm, fn [_, amt, color | []] ->
          %Move{
            color: color,
            amount: String.to_integer(amt)
          }
        end)
      end)
      |> then(&%Game{
        id: String.to_integer(id),
        moves: &1
      })
    end)
  end
end

with {:ok, contents} <- File.read('input.txt') do
  games = String.split(contents, "\n", trim: true)
  |> AdventOfCode.parse

  AdventOfCode.check(games, %{
    "red" => 12,
    "green" => 13,
    "blue" => 14
  })
  |> AdventOfCode.sum_ids
  |> IO.inspect(label: "Part 1")

  AdventOfCode.compute_power(games)
  |> IO.inspect(label: "Part 2")
else
  _ -> IO.inspect("Failed to read input file!")
end
