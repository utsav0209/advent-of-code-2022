defmodule Day10 do
  @track_cycles [20, 60, 100, 140, 180, 220]

  defp track(x, cycle, signals) when rem(cycle - 20, 40) == 0, do: signals ++ [x * cycle]

  defp track(_, _, signals), do: signals

  defp execute(command, {x, cycle, signals}) do
    signals = track(x, cycle + 1, signals)

    case command do
      "noop" ->
        {x, cycle + 1, signals}

      "addx " <> count ->
        signals = track(x, cycle + 2, signals)
        {x + String.to_integer(count), cycle + 2, signals}
    end
  end

  defp get_symbol(x, cycle) when abs(rem(cycle - 1, 40) - x) <= 1, do: '#'
  defp get_symbol(x, cycle), do: '.'

  defp trace(x, cycle, []) do
    [[get_symbol(x, cycle)]]
  end

  defp trace(x, cycle, [head | tail]) do
    symbol = get_symbol(x, cycle)

    if rem(cycle - 1, 40) == 0 do
      [[symbol] | [head | tail]]
    else
      [[symbol | head] | tail]
    end
  end

  defp draw(command, {x, cycle, drawing}) do
    drawing = trace(x, cycle + 1, drawing)

    case command do
      "noop" ->
        {x, cycle + 1, drawing}

      "addx " <> count ->
        drawing = trace(x, cycle + 2, drawing)
        {x + String.to_integer(count), cycle + 2, drawing}
    end
  end

  defp read_input() do
    File.stream!("lib/inputs/day_10.input", [:read])
    |> Stream.map(fn str -> String.trim_trailing(str, "\n") end)
    |> Enum.to_list()
  end

  def solve_1() do
    read_input()
    |> Enum.reduce({1, 0, []}, fn command, acc -> execute(command, acc) end)
    |> elem(2)
    |> Enum.sum()
  end

  def solve_2() do
    read_input()
    |> Enum.reduce({1, 0, []}, fn command, acc -> draw(command, acc) end)
    |> elem(2)
    |> Enum.reverse()
    |> Enum.map(fn x -> Enum.reverse(x) |> Enum.join(" ") end)
    |> Enum.join("\n")
  end
end

IO.puts("Solve 1: #{Day10.solve_1()}")
IO.puts("Solve 2: \n#{Day10.solve_2()}")
