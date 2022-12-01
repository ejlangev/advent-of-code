with {:ok, contents} <- File.read('input.txt') do
  String.split(contents, "\n\n", trim: true)
  |> Enum.map(fn l -> String.split(l, "\n", trim: true) |> Enum.map(&String.to_integer/1) end)
  |> Enum.map(&Enum.sum/1)
  |> tap(fn input -> Enum.max(input) |> IO.inspect(label: "Part 1 Answer") end)
  |> Enum.sort_by(&(&1), :desc)
  |> Enum.take(3)
  |> Enum.sum
  |> IO.inspect(label: "Part 2 Answer")
else
  _ -> IO.inspect("Failed to read input file")
end
