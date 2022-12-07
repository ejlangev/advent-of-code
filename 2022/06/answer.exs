with {:ok, contents} <- File.read('input.txt') do
  String.split(contents, "\n", trim: true)
  |> List.first
  |> String.split("", trim: true)
  |> tap(fn input ->
    Stream.chunk_every(input, 4, 1, :discard)
    |> Stream.with_index
    |> Stream.take_while(fn {v, _} -> length(Enum.uniq(v)) != length(v) end)
    |> then(&Enum.count(&1) + 4)
    |> IO.inspect(label: "Part 1 Answer")
  end)
  |> Stream.chunk_every(14, 1, :discard)
  |> Stream.with_index
  |> Stream.take_while(fn {v, _} -> length(Enum.uniq(v)) != length(v) end)
  |> then(&Enum.count(&1) + 14)
  |> IO.inspect(label: "Part 2 Answer")
else
  _ -> IO.inspect("Failed to read input file")
end
