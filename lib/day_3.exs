defmodule Day3 do
  defp read_input() do
    File.stream!("lib/inputs/day_3.input", [:read])
    |> Stream.map(&String.trim_trailing/1)
    |> Enum.to_list()
  end

  defp split_in_half(lst) do
    Enum.split(lst, Integer.floor_div(length(lst), 2))
  end

  defp get_priority(c) do
    cond do
      String.upcase(c) == c -> :binary.first(c) - ?A + 27
      true -> :binary.first(c) - ?a + 1
    end
  end

  defp get_common_elements({l1, l2}) do
    l1 -- l1 -- l2
  end

  defp get_common_elements({l1, l2, l3}) do
    common_between_first_two = get_common_elements({l1, l2})
    get_common_elements({common_between_first_two, l3})
  end

  def solve_1() do
    read_input()
    |> Enum.map(&String.graphemes/1)
    |> Enum.map(&split_in_half/1)
    |> Enum.map(&get_common_elements/1)
    |> Enum.map(&hd/1)
    |> Enum.map(&get_priority/1)
    |> Enum.sum()
  end

  def solve_2() do
    read_input()
    |> Enum.map(&String.graphemes/1)
    |> Enum.chunk_every(3)
    |> Enum.map(&List.to_tuple/1)
    |> Enum.map(&get_common_elements/1)
    |> Enum.map(&hd/1)
    |> Enum.map(&get_priority/1)
    |> Enum.sum()
  end
end

IO.puts("Solve 1: #{Day3.solve_1()}")
IO.puts("Solve 2: #{Day3.solve_2()}")
