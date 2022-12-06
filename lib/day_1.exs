defmodule Day1 do
  defp read_input() do
    File.stream!("lib/inputs/day_1.input", [:read])
    |> Stream.map(&String.trim_trailing/1)
    |> Enum.to_list()
  end

  defp get_calories_per_elf() do
    read_input()
    |> Enum.reduce([], fn
      s, [] -> [String.to_integer(s)]
      "", acc -> [0] ++ acc
      n, [h | t] -> [String.to_integer(n) + h] ++ t
    end)
    |> Enum.reverse()
  end

  def solve_1() do
    get_calories_per_elf()
    |> Enum.max()
  end

  def solve_2() do
    get_calories_per_elf()
    |> Enum.sort()
    |> Enum.take(-3)
    |> Enum.sum()
  end
end

IO.puts("Solve 1: #{Day1.solve_1()}")
IO.puts("Solve 2: #{Day1.solve_2()}")
