defmodule Day24 do
  defp read_input() do
    File.read!("lib/inputs/day_24.input")
    |> to_string()
  end

  def solve_1() do
    {blizzards, {maxR, maxC}} = read_input() |> parse_input()

    {steps, _} = travel(blizzards, {-1, 0}, {maxR, maxC - 1}, {maxR, maxC})

    steps
  end

  def solve_2() do
    {blizzards, {maxR, maxC}} = read_input() |> parse_input()

    {steps_1, blizzards} = travel(blizzards, {-1, 0}, {maxR, maxC - 1}, {maxR, maxC})
    {steps_2, blizzards} = travel(blizzards, {maxR, maxC - 1}, {-1, 0}, {maxR, maxC})
    {steps_3, _} = travel(blizzards, {-1, 0}, {maxR, maxC - 1}, {maxR, maxC})

    steps_1 + steps_2 + steps_3
  end

  defp parse_input(input_str) do
    input_str
    |> String.split("\n", trim: true)
    |> Enum.with_index(-1)
    |> Enum.reduce({[], {0, 0}}, &parse_row/2)
  end

  defp parse_row({row, row_index}, acc) do
    row
    |> String.graphemes()
    |> Enum.with_index(-1)
    |> Enum.reduce(acc, fn {col, col_index}, {blizzards, {maxR, maxC}} ->
      maxR = max(maxR, row_index)
      maxC = max(maxC, col_index)

      blizzards =
        case col do
          "." -> blizzards
          "#" -> blizzards
          "^" -> [{{row_index, col_index}, :N} | blizzards]
          ">" -> [{{row_index, col_index}, :E} | blizzards]
          "v" -> [{{row_index, col_index}, :S} | blizzards]
          "<" -> [{{row_index, col_index}, :W} | blizzards]
        end

      {blizzards, {maxR, maxC}}
    end)
  end

  defp travel(blizzards, initial_pos, target_pos, boundaries) do
    Stream.iterate(1, &(&1 + 1))
    |> Enum.reduce_while(
      {blizzards, MapSet.new([initial_pos])},
      &run_step(&1, &2, boundaries, target_pos)
    )
  end

  defp run_step(step, {blizzards, current_positions}, boundaries, target_pos) do
    new_blizzards = Enum.map(blizzards, &step_blizzard(&1, boundaries))
    blizzset = new_blizzards |> Enum.map(&elem(&1, 0)) |> Enum.sort() |> MapSet.new()

    new_positions =
      Enum.map(current_positions, &update_position(&1, blizzset, boundaries))
      |> List.flatten()
      |> MapSet.new()

    if MapSet.member?(new_positions, target_pos) do
      {:halt, {step, new_blizzards}}
    else
      {:cont, {new_blizzards, new_positions}}
    end
  end

  defp step_blizzard({current_pos, direction}, {maxR, maxC}) do
    {r, c} = get_next_pos(current_pos, direction)
    {{Integer.mod(r, maxR), Integer.mod(c, maxC)}, direction}
  end

  defp get_next_pos({r, c}, :N), do: {r - 1, c}
  defp get_next_pos({r, c}, :S), do: {r + 1, c}
  defp get_next_pos({r, c}, :E), do: {r, c + 1}
  defp get_next_pos({r, c}, :W), do: {r, c - 1}

  defp update_position(position, blizzards, {maxR, maxC}) do
    [:N, :S, :E, :W]
    |> Enum.map(&get_next_pos(position, &1))
    |> List.insert_at(0, position)
    |> Enum.filter(fn {r, c} ->
      {r, c} == {-1, 0} or {r, c} == {maxR, maxC - 1} or
        (r >= 0 and r < maxR and c >= 0 and c < maxC)
    end)
    |> Enum.filter(&(not MapSet.member?(blizzards, &1)))
  end
end

IO.puts("Solve 1: #{Day24.solve_1()}")
IO.puts("Solve 2: #{Day24.solve_2()}")
