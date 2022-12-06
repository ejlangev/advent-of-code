with {:ok, contents} <- File.read('input.txt') do
  String.split(contents, "\n", trim: true)
  |> Enum.map(&Regex.scan(~r/\d+/, &1))
  |> List.flatten
  |> Enum.map(&String.to_integer/1)
  |> Enum.chunk_every(4)
  |> Enum.map(&List.to_tuple/1)
  |> tap(fn data ->
    Enum.count(data, fn {a, b, c, d} ->
      (a <= c and b >= d) or (c <= a and d >= b)
    end)
    |> IO.inspect(label: "Part 1 Answer")
  end)
  |> Enum.count(fn {a, b, c, d} -> !Range.disjoint?(Range.new(a, b), Range.new(c, d)) end)
  |> IO.inspect(label: "Part 2 Answer")
else
  _ -> IO.inspect("Failed to read input file")
end
