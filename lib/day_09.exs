defmodule Day9 do
  defp read_input() do
    File.stream!("lib/inputs/day_09.input", [:read])
    |> Stream.map(fn str -> String.trim_trailing(str, "\n") end)
    |> Enum.to_list()
    |> Enum.map(&String.split/1)
    |> Enum.map(&List.to_tuple/1)
  end

  def solve_1() do
    read_input()
    |> Enum.reduce(
      {List.duplicate({0, 0}, 2), MapSet.new([{0, 0}])},
      &make_moves/2
    )
    |> elem(1)
    |> MapSet.size()
  end

  def solve_2() do
    read_input()
    |> Enum.reduce(
      {List.duplicate({0, 0}, 10), MapSet.new([{0, 0}])},
      &make_moves/2
    )
    |> elem(1)
    |> MapSet.size()
  end

  defguard is_touching(tail, head)
           when abs(elem(head, 0) - elem(tail, 0)) <= 1 and
                  abs(elem(head, 1) - elem(tail, 1)) <= 1

  def step_towards(from, to) when from == to, do: from
  def step_towards(from, to) when from < to, do: from + 1
  def step_towards(from, to) when from > to, do: from - 1

  defp move_tail(tail, head) when is_touching(tail, head), do: tail

  defp move_tail({tx, ty}, {hx, hy}), do: {step_towards(tx, hx), step_towards(ty, hy)}

  defp move_head({x, y}, direction) do
    case direction do
      "R" -> {x + 1, y}
      "L" -> {x - 1, y}
      "U" -> {x, y + 1}
      "D" -> {x, y - 1}
    end
  end

  defp make_a_move(direction, {[head | tail], visited_locs}) do
    new_tail =
      Enum.reduce(
        tail,
        [move_head(head, direction)],
        fn t, acc -> [move_tail(t, hd(acc)) | acc] end
      )

    new_visited_locs = MapSet.put(visited_locs, hd(new_tail))

    {Enum.reverse(new_tail), new_visited_locs}
  end

  defp make_moves({direction, steps}, {rope, visited_locs}) do
    Enum.reduce(
      1..String.to_integer(steps),
      {rope, visited_locs},
      fn _, acc -> make_a_move(direction, acc) end
    )
  end
end

IO.puts("Solve 1: #{Day9.solve_1()}")
IO.puts("Solve 2: #{Day9.solve_2()}")
