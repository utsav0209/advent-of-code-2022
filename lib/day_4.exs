defmodule Day4 do
  defp read_input() do
    File.stream!("lib/inputs/day_4.input", [:read])
    |> Stream.map(&String.trim_trailing/1)
    |> Enum.to_list()
  end

  def parse_range_pair(pair) do
    String.split(pair, ",")
    |> Enum.map(fn range ->
      String.split(range, "-")
      |> Enum.map(&String.to_integer/1)
      |> Enum.to_list()
      |> List.to_tuple()
    end)
    |> List.to_tuple()
  end

  def get_assignment_pairs() do
    read_input()
    |> Enum.map(&parse_range_pair/1)
  end

  def covers_whole_range({{l1, r1}, {l2, r2}}) do
    (l2 <= l1 and r1 <= r2) or (l1 <= l2 and r2 <= r1)
  end

  def does_overlap({{l1, r1}, {l2, r2}}) do
    cond do
      l1 < l2 ->
        l2 <= r1

      true ->
        l1 <= r2
    end
  end

  def solve_1() do
    read_input()
    |> Enum.map(&parse_range_pair/1)
    |> Enum.filter(&covers_whole_range/1)
    |> length()
  end

  def solve_2() do
    read_input()
    |> Enum.map(&parse_range_pair/1)
    |> Enum.filter(&does_overlap/1)
    |> length()
  end
end

IO.puts("Solve 1: #{Day4.solve_1()}")
IO.puts("Solve 2: #{Day4.solve_2()}")
