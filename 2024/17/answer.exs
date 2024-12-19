import Bitwise

defmodule AdventOfCode do
  @spec solve_part_one(String.t()) :: Integer.t()
  def solve_part_one(contents) do
    {registers, instructions} = parse_input(contents)

    run_program(registers, instructions)
    |> Enum.map(&Integer.to_string/1)
    |> Enum.join
  end

  @spec solve_part_two(String.t()) :: Integer.t()
  def solve_part_two(contents) do
    {_, instructions} = parse_input(contents)

    Enum.reverse(instructions)
    |> Enum.reduce([0], fn out, acc ->
      Enum.flat_map(acc, fn current ->
        Enum.map(Range.new(0, 7), fn i ->
          input = bsl(current, 3) + i

          run_program({input, 0, 0}, instructions)
          |> List.first
          |> then(fn result ->
            if result == out, do: input, else: nil
          end)
        end)
        |> Enum.filter(&(&1 != nil))
      end)
    end)
    |> Enum.sort(:asc)
    |> Enum.find(&(run_program({&1, 0, 0}, instructions) == instructions))
  end

  defp parse_input(contents) do
    registers = Regex.scan(~r/Register ([A-C]): (\d+)/, contents, capture: :all_but_first)
    |> Enum.reduce({nil, nil, nil}, fn [reg, val], {reg_a, reg_b, reg_c} ->
      case reg do
        "A" -> {String.to_integer(val), reg_b, reg_c}
        "B" -> {reg_a, String.to_integer(val), reg_c}
        "C" -> {reg_a, reg_b, String.to_integer(val)}
      end
    end)

    Regex.run(~r/Program: ([0-7,]+)/, contents, capture: :all_but_first)
    |> hd
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> then(&{registers, &1})
  end

  defp run_program({i_a, i_b, i_c}, instructions) do
    Stream.unfold({i_a, i_b, i_c, 0}, fn {reg_a, reg_b, reg_c, inst_pntr} ->
      if inst_pntr >= length(instructions) do
        nil
      else
        [opcode, operand] = Enum.slice(instructions, inst_pntr, 2)
        combo_val = case operand do
          i when i >= 0 and i <= 3 -> i
          4 -> reg_a
          5 -> reg_b
          6 -> reg_c
          7 -> nil
        end


        case opcode do
          0 -> {nil, {floor(reg_a / :math.pow(2, combo_val)), reg_b, reg_c, inst_pntr + 2}}
          1 -> {nil, {reg_a, bxor(reg_b, operand), reg_c, inst_pntr + 2}}
          2 -> {nil, {reg_a, rem(combo_val, 8), reg_c, inst_pntr + 2}}
          3 -> {nil, {reg_a, reg_b, reg_c, (if reg_a == 0, do: inst_pntr + 2, else: operand)}}
          4 -> {nil, {reg_a, bxor(reg_b, reg_c), reg_c, inst_pntr + 2}}
          5 -> {rem(combo_val, 8), {reg_a, reg_b, reg_c, inst_pntr + 2}}
          6 -> {nil, {reg_a, floor(reg_a / :math.pow(2, combo_val)), reg_c, inst_pntr + 2}}
          7 -> {nil, {reg_a, reg_b, floor(reg_a / :math.pow(2, combo_val)), inst_pntr + 2}}
        end
      end
    end)
    |> Stream.filter(&(&1 != nil))
    |> Enum.to_list
  end
end


with {:ok, contents} <- File.read("input.txt") do
  AdventOfCode.solve_part_one(contents) |> IO.inspect(label: "Part 1")
  AdventOfCode.solve_part_two(contents) |> IO.inspect(label: "Part 2")
else
  _ -> IO.inspect("Failed to read input file!")
end
