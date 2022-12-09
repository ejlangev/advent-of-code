defmodule AdventOfCode do
  defmodule File do
    defstruct [:name, :size]
  end

  defmodule Directory do
    defstruct [:name, files: [], subdirectories: [], size: 0]
  end

  def find_smaller(%Directory{subdirectories: [], size: size}, max) when size < max, do: size
  def find_smaller(%Directory{subdirectories: [], size: size}, max) when size >= max, do: 0
  def find_smaller(dir, max) do
    Enum.map(dir.subdirectories, &(find_smaller(&1, max)))
    |> Enum.sum
    |> then(&(if dir.size < max, do: dir.size + &1, else: &1))
  end

  def find_deletion_size(root) do
    needed_space = root.size - 40000000

    get_dir_sizes(root)
    |> Enum.filter(&(&1 > needed_space))
    |> Enum.sort
    |> List.first
  end

  def parse(input), do: compute_size(parse(input, {"/", %Directory{name: "/"}}))
  def parse([], {_, root}), do: root
  def parse([elm | rest], {cwd, root}) do
    case elm do
      "$ cd .." -> parse(rest, {Path.expand(cwd <> "/.."), root})
      "$ cd /" -> parse(rest, {"/", root})
      "$ cd " <> name -> parse(rest, {cwd <> "/" <> name, root})
      "$ ls" -> parse(rest, {cwd, root})
      "dir " <> dir -> parse(rest, {cwd, insert_dirent(root, cwd, %Directory{name: dir})})
      _ ->
        String.split(elm, " ", trim: true)
        |> List.to_tuple
        |> then(fn {size, name} -> parse(rest, {cwd, insert_dirent(root, cwd, %File{name: name, size: String.to_integer(size)})}) end)
    end
  end

  def compute_size(%Directory{subdirectories: [], files: files} = dir), do: %{dir | size: Enum.map(files, &(&1.size)) |> Enum.sum}
  def compute_size(dir) do
    file_size = Enum.map(dir.files, &(&1.size)) |> Enum.sum
    Enum.map(dir.subdirectories, &compute_size(&1))
    |> then(&{&1, Enum.map(&1, fn s -> s.size end) |> Enum.sum})
    |> then(fn {subs, sub_size} -> %{dir | subdirectories: subs, size: sub_size + file_size} end )
  end

  defp insert_dirent(dir, "", %Directory{} = dirent), do: %{dir | subdirectories: [dirent | dir.subdirectories]}
  defp insert_dirent(dir, "/", %Directory{} = dirent), do: %{dir | subdirectories: [dirent | dir.subdirectories]}
  defp insert_dirent(dir, "", %File{} = dirent), do: %{dir | files: [dirent | dir.files]}
  defp insert_dirent(dir, "/", %File{} = dirent), do: %{dir | files: [dirent | dir.files]}
  defp insert_dirent(dir, path, dirent) do
    [head | tl] = String.split(path, "/", trim: true)
    Enum.map(dir.subdirectories, fn s -> (if s.name == head, do: insert_dirent(s, Enum.join(tl, "/"), dirent), else: s) end)
    |> then(&%{dir | subdirectories: &1})
  end

  defp get_dir_sizes(%Directory{subdirectories: [], size: size}), do: [size]
  defp get_dir_sizes(dir) do
    Enum.map(dir.subdirectories, &get_dir_sizes/1)
    |> List.flatten
    |> then(&[dir.size | &1])
  end
end

with {:ok, contents} <- File.read('input.txt') do
  String.split(contents, "\n", trim: true)
  |> AdventOfCode.parse
  |> tap(fn input ->
    AdventOfCode.find_smaller(input, 100000)
    |> IO.inspect(label: "Part 1 Answer")
  end)
  |> AdventOfCode.find_deletion_size
  |> IO.inspect(label: "Part 2 Answer")
else
  _ -> IO.inspect("Failed to read input file")
end
