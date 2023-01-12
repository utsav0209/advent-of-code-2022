defmodule Day23 do
  defp read_input() do
    File.read!("lib/inputs/day_23.input")
    |> to_string()
  end

  def solve_1() do
    groove = read_input() |> parse_input()
    directions = [:N, :S, :W, :E]

    make_moves(groove, directions, 10)
    |> count_empty_tiles()
  end

  def solve_2() do
    groove = read_input() |> parse_input()
    directions = [:N, :S, :W, :E]

    first_halting_round(groove, directions, 1)
  end

  defp parse_input(input_str) do
    input_str
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%MapSet{}, &parse_row/2)
  end

  defp parse_row({row_str, row_index}, groove) do
    row_str
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce(groove, fn {col, col_index}, acc_groove ->
      case col == "#" do
        true -> MapSet.put(acc_groove, {row_index, col_index})
        false -> acc_groove
      end
    end)
  end

  defp make_moves(groove, _, 0), do: groove

  defp make_moves(groove, [h | t] = directions, moves_left) do
    calculate_jumps(groove, directions)
    |> make_jumps(groove)
    |> make_moves(t ++ [h], moves_left - 1)
  end

  defp first_halting_round(groove, [h | t] = directions, round) do
    jumps = calculate_jumps(groove, directions)

    case map_size(jumps) do
      0 ->
        round

      _ ->
        make_jumps(jumps, groove)
        |> first_halting_round(t ++ [h], round + 1)
    end
  end

  defp calculate_jumps(groove, directions) do
    Enum.reduce(
      groove,
      %{},
      fn curr_location, next_locations ->
        neighbors = get_neighbors(curr_location)

        case MapSet.disjoint?(groove, neighbors) do
          true ->
            next_locations

          false ->
            case calculate_jump_if_any(groove, curr_location, directions) do
              nil ->
                next_locations

              target_location ->
                other_monkeys_at_target = Map.get(next_locations, target_location, [])

                Map.put(
                  next_locations,
                  target_location,
                  other_monkeys_at_target ++ [curr_location]
                )
            end
        end
      end
    )
  end

  defp calculate_jump_if_any(groove, curr_location, directions) do
    Enum.reduce_while(directions, nil, fn direction, acc ->
      case MapSet.disjoint?(groove, get_neighbors(curr_location, direction)) do
        true ->
          {:halt, get_jump_location(curr_location, direction)}

        false ->
          {:cont, acc}
      end
    end)
  end

  defp get_jump_location({r, c}, :N), do: {r - 1, c}
  defp get_jump_location({r, c}, :S), do: {r + 1, c}
  defp get_jump_location({r, c}, :E), do: {r, c + 1}
  defp get_jump_location({r, c}, :W), do: {r, c - 1}

  defp get_neighbors({r, c} = current_location) do
    neighbors = for dr <- [0, -1, 1], dc <- [0, -1, 1], do: {r + dr, c + dc}

    neighbors
    |> Enum.filter(fn neighbor -> neighbor != current_location end)
    |> MapSet.new()
  end

  defp get_neighbors({r, c}, :N), do: MapSet.new([{r - 1, c - 1}, {r - 1, c}, {r - 1, c + 1}])
  defp get_neighbors({r, c}, :S), do: MapSet.new([{r + 1, c - 1}, {r + 1, c}, {r + 1, c + 1}])
  defp get_neighbors({r, c}, :E), do: MapSet.new([{r - 1, c + 1}, {r, c + 1}, {r + 1, c + 1}])
  defp get_neighbors({r, c}, :W), do: MapSet.new([{r - 1, c - 1}, {r, c - 1}, {r + 1, c - 1}])

  defp make_jumps(jumps, groove) do
    jumps = Map.filter(jumps, fn {_, v} -> length(v) == 1 end)

    source_locations = Map.values(jumps) |> List.flatten() |> MapSet.new()
    target_locations = Map.keys(jumps) |> MapSet.new()

    groove
    |> MapSet.difference(source_locations)
    |> MapSet.union(target_locations)
  end

  defp count_empty_tiles(groove) do
    groove = MapSet.to_list(groove)

    row_span =
      groove
      |> Enum.map(fn {r, _} -> r end)
      |> then(fn rows -> abs(Enum.max(rows) - Enum.min(rows)) + 1 end)

    col_span =
      groove
      |> Enum.map(fn {_, c} -> c end)
      |> then(fn cols -> abs(Enum.max(cols) - Enum.min(cols)) + 1 end)

    row_span * col_span - length(groove)
  end
end

IO.puts("Solve 1: #{Day23.solve_1()}")
IO.puts("Solve 2: #{Day23.solve_2()}")
