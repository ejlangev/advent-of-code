defmodule AdventOfCode do
  defmodule Hand do
    @type t :: %__MODULE__{
      hand: String.t(),
      bid: integer(),
      strength: atom(),
      powers: list(integer())
    }
    defstruct [:hand, :bid, :strength, :powers]
  end

  @card_strengths %{
    "A" => 14,
    "K" => 13,
    "Q" => 12,
    "J" => 11,
    "T" => 10
  }

  @hand_strengths %{
    :five_of_kind => 7,
    :four_of_kind => 6,
    :full_house => 5,
    :three_of_kind => 4,
    :two_pair => 3,
    :one_pair => 2,
    :high_card => 1
  }

  @spec parse(String.t(), boolean()) :: list(Hand.t())
  def parse(contents, use_jokers \\ false) do
    card_strengths = if use_jokers, do: Map.put(@card_strengths, "J", 1), else: @card_strengths

    String.split(contents, "\n", trim: true)
    |> Enum.map(&String.split(&1, " ", trim: true) |> List.to_tuple)
    |> Enum.map(fn {hand, bid} ->
      powers = String.split(hand, "", trim: true)
        |> Enum.map(&Map.get_lazy(card_strengths, &1, fn -> String.to_integer(&1) end))

      %Hand{
        hand: hand,
        bid: String.to_integer(bid),
        strength: hand_to_strength(hand, use_jokers),
        powers: powers
      }
    end)
  end

  @spec solve(list(Hand.t())) :: integer()
  def solve(hands) do
    Enum.sort_by(hands, fn hand ->
      {Map.fetch!(@hand_strengths, hand.strength), List.to_tuple(hand.powers)}
    end)
    |> Enum.with_index
    |> Enum.map(fn {elm, i} -> elm.bid * (i + 1) end)
    |> Enum.sum
  end

  @spec hand_to_strength(String.t(), boolean()) :: atom()
  defp hand_to_strength(hand, use_jokers) do
    joker_count = if use_jokers do
      String.split(hand, "", trim: true) |> Enum.filter(&(&1 == "J")) |> Enum.count
    else
      0
    end
    frequencies = String.split(hand, "", trim: true)
      |> Enum.group_by(fn x -> x end)
      |> Map.values
      |> Enum.map(&Enum.count/1)
      |> Enum.sort(:desc)
      |> List.to_tuple

    case {frequencies, joker_count} do
      {{5}, _} -> :five_of_kind

      {{4, _}, 4} -> :five_of_kind
      {{4, _}, 1} -> :five_of_kind
      {{4, _}, 0} -> :four_of_kind

      {{3, 2}, 3} -> :five_of_kind
      {{3, 2}, 2} -> :five_of_kind
      {{3, 2}, 0} -> :full_house

      {{3, _, _}, 3} -> :four_of_kind
      {{3, _, _}, 1} -> :four_of_kind
      {{3, _, _}, 0} -> :three_of_kind

      {{2, 2, _}, 2} -> :four_of_kind
      {{2, 2, _}, 1} -> :full_house
      {{2, 2, _}, 0} -> :two_pair

      {{2, _, _, _}, 2} -> :three_of_kind
      {{2, _, _, _}, 1} -> :three_of_kind
      {{2, _, _, _}, 0} -> :one_pair
      {_, 1} -> :one_pair
      _ -> :high_card
    end
  end
end

with {:ok, contents} <- File.read('input.txt') do
  AdventOfCode.parse(contents)
  |> AdventOfCode.solve
  |> IO.inspect(label: "Part 1")

  AdventOfCode.parse(contents, true)
  |> AdventOfCode.solve
  |> IO.inspect(label: "Part 2")
else
  _ -> IO.inspect("Failed to read input file!")
end
