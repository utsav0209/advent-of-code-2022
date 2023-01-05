defmodule Day20 do
  @decryption_key 811_589_153

  defp read_input() do
    File.read!("lib/inputs/day_20.input")
    |> to_string()
  end

  def solve_1() do
    read_input()
    |> parse()
    |> Enum.with_index()
    |> then(fn numbers -> mix(numbers, numbers) end)
    |> Enum.map(fn {number, _} -> number end)
    |> get_co_ordinates()
    |> Enum.sum()
  end

  def solve_2() do
    initial =
      read_input()
      |> parse()
      |> Enum.map(fn number -> number * @decryption_key end)
      |> Enum.with_index()

    1..10
    |> Enum.reduce(initial, fn _, acc -> mix(initial, acc) end)
    |> Enum.map(fn {number, _} -> number end)
    |> get_co_ordinates()
    |> Enum.sum()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp mix(initial, current_numbers) do
    len = length(initial)

    initial
    |> Enum.reduce(current_numbers, fn {number, _} = to_shift, acc ->
      current_position = Enum.find_index(acc, fn x -> x == to_shift end)

      move_by = Integer.mod(number, len - 1)
      offset = if current_position + move_by >= len, do: 1, else: 0

      new_position = Integer.mod(current_position + move_by, len) + offset

      acc
      |> List.delete_at(current_position)
      |> List.insert_at(new_position, to_shift)
    end)
  end

  defp get_co_ordinates(numbers) do
    zero_index = Enum.find_index(numbers, fn x -> x == 0 end)

    [1000, 2000, 3000]
    |> Enum.map(fn offset -> Integer.mod(offset + zero_index, length(numbers)) end)
    |> Enum.map(fn index -> Enum.at(numbers, index) end)
  end
end

IO.puts("Solve 1: #{Day20.solve_1()}")
IO.puts("Solve 2: #{Day20.solve_2()}")
