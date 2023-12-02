defmodule AdventOfCode do
  def solve(entries, time), do: solve(entries, time, "AA", Map.new, MapSet.new)
  def solve(_, 0, _, memo, opened), do: {[{0, opened}], memo}
  def solve(entries, time, current, memo, opened) do
    memo_key = {current, time, Enum.sort(opened) |> Enum.join("|")}
    if Map.get(memo, memo_key) do
      {Map.get(memo, memo_key), memo}
    else
      {flow_rate, next_options} = Map.get(entries, current)
      Enum.reduce(next_options, {[], memo}, fn next, {results, new_memo} ->

        # Don't bother with opening this if the flow rate is 0
        # and also don't try if there isn't time
        if flow_rate > 0 and time > 1 and not MapSet.member?(opened, current) do
          {open_results, open_memo} = solve(entries, time - 2, next, new_memo, MapSet.put(opened, current))
          final_open_results = Enum.map(open_results, &{elem(&1, 0) + flow_rate * (time - 1), elem(&1, 1)})
          {final_open_results ++ results, open_memo}
        else
          {no_open_results, no_open_memo} = solve(entries, time - 1, next, new_memo, opened)
          {no_open_results ++ results, no_open_memo}
        end
      end)
      |> then(fn {results, new_memo} ->
        # final_results = Enum.map(results, &{elem(&1, 0), [current | elem(&1, 1)]}) |> prune_results
        final_results = Enum.map(results, &{elem(&1, 0), MapSet.put(elem(&1, 1), current)}) |> prune_results
        {final_results, Map.put(new_memo, memo_key, final_results)}
      end)
    end
  end

  defp prune_results(results) do
    Enum.group_by(results, &elem(&1, 1))
    |> Enum.flat_map(fn {_, vals} ->
      max_value = Enum.max_by(vals, &elem(&1, 0)) |> elem(0)
      Enum.filter(vals, &elem(&1, 0) == max_value)
    end)
  end
end

with {:ok, contents} <- File.read('input.txt') do
  String.split(contents, "\n", trim: true)
  |> Enum.map(&Regex.run(~r/^Valve ([A-Z]+) has flow rate=(\d+); tunnel[s]* lead[s]* to valve[s]* ([A-Z\ ,]+)*$/, &1) |> tl)
  |> Enum.map(&{hd(&1), {String.to_integer(Enum.at(&1, 1)), String.split(Enum.at(&1, 2), ",", trim: true) |> Enum.map(fn x -> String.trim(x) end)}})
  |> Map.new
  |> tap(fn input ->
    AdventOfCode.solve(input, 20)
    |> elem(0)
    |> Enum.max_by(&elem(&1, 0))
    |> IO.inspect
    |> elem(0)
    |> IO.inspect(label: "Part 1 Answer")
  end)
  # |> then(fn input ->
  #   {my_total, memo, _} = AdventOfCode.solve(input, 26)
  #   IO.inspect({my_total, memo})
  # end)
  # |> IO.inspect
else
  _ -> IO.inspect("Failed to read input file")
end
