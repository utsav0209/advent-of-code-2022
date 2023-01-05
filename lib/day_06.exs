defmodule Day6 do
  defp read_input() do
    File.stream!("lib/inputs/day_06.input", [:read])
    |> Stream.map(fn str -> String.trim_trailing(str, "\n") end)
    |> Enum.to_list()
    |> Enum.at(0)
    |> String.graphemes()
  end

  def solve_1() do
    read_input()
    |> find_marker(0, 4)
  end

  def solve_2() do
    read_input()
    |> find_marker(0, 14)
  end

  defp find_marker([_skip | rest] = message, index, size) do
    window = Enum.take(message, size)

    if Enum.uniq(window) == window do
      index + size
    else
      find_marker(rest, index + 1, size)
    end
  end
end

IO.puts("Solve 1: #{Day6.solve_1()}")
IO.puts("Solve 2: #{Day6.solve_2()}")
