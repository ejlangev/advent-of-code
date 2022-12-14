with {:ok, contents} <- File.read('input.txt') do
  String.split(contents, "\n", trim: true)
  |> Stream.transform(1, fn elm, acc ->
    case elm do
      "addx " <> val -> {[acc, acc], acc + String.to_integer(val)}
      _ -> {[acc], acc}
    end
  end)
  |> tap(fn s ->
    Stream.drop(s, 19)
    |> Stream.take_every(40)
    |> Stream.take(6)
    |> Stream.with_index
    |> Stream.map(fn {val, i} -> val * (i*40 + 20) end)
    |> Enum.to_list
    |> Enum.sum
    |> IO.inspect(label: "Part 1 Answer")
  end)
  |> Stream.take(240)
  |> Stream.with_index
  |> Stream.map(fn {val, i} ->
    if rem(i, 40) >= val - 1 && rem(i, 40) <= val + 1, do: "#", else: "."
  end)
  |> Stream.chunk_every(40)
  |> Enum.to_list
  |> Enum.map(&Enum.join(&1, ""))
  |> Enum.join("\n")
  |> tap(fn _ -> IO.puts("Part 2 Answer:") end)
  |> IO.puts

else
  _ -> IO.inspect("Failed to read input file")
end
