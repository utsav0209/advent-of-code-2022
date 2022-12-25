defmodule Day15 do
  @target_row 2_000_000
  @max_size 4_000_000

  defp read_input() do
    File.read!("lib/inputs/day_15.input")
    |> to_string()
  end

  def solve_1() do
    state =
      read_input()
      |> parse_input()

    locations =
      state
      |> calculate_impossible_locations()
      |> merge_intervals()
      |> Enum.map(fn [s, e] -> e - s + 1 end)
      |> Enum.sum()

    locations - length(Enum.uniq(state.beacons_at_target_row))
  end

  def solve_2() do
    read_input()
    |> parse_input()
    |> distress_point()
    |> tuning_signal()
  end

  defp parse_input(input) do
    state = %{sensors: %{}, beacons: %{}, beacons_at_target_row: [], impossible_ranges: []}

    String.split(input, "\n")
    |> Enum.reduce(state, &parse_s_and_b/2)
  end

  defp parse_s_and_b(s_and_b_str, state) do
    ["Sensor at x=" <> sensor_str, " closest beacon is at x=" <> beacon_str] =
      String.split(s_and_b_str, ":")

    [s_x, s_y] = String.split(sensor_str, ", y=") |> Enum.map(&String.to_integer/1)
    [b_x, b_y] = String.split(beacon_str, ", y=") |> Enum.map(&String.to_integer/1)

    distance = manhattan_distance({s_x, s_y}, {b_x, b_y})

    state = %{state | sensors: Map.put(state.sensors, {s_x, s_y}, distance)}
    state = %{state | beacons: Map.put(state.beacons, {b_x, b_y}, distance)}

    if(b_y == @target_row) do
      %{
        state
        | beacons_at_target_row: state.beacons_at_target_row ++ [{b_x, b_y}]
      }
    else
      state
    end
  end

  defp manhattan_distance({x1, y1}, {x2, y2}), do: abs(x2 - x1) + abs(y2 - y1)

  defp calculate_impossible_locations(state) do
    state.sensors
    |> Enum.map(&get_impossible_range(&1, @target_row))
    |> Enum.reject(&is_nil/1)
  end

  defp get_impossible_range({{x, y}, distance_to_beacon}, target_row) do
    length = distance_to_beacon - abs(target_row - y)

    if length >= 0 do
      [x - length, x + length]
    end
  end

  defp merge_intervals(intervals) do
    [head | tail] = intervals |> Enum.sort()

    Enum.reduce(tail, [head], &merge_intervals/2) |> Enum.reverse()
  end

  defp merge_intervals([next_start, next_end] = next, [[head_start, head_end] | tail] = acc) do
    if head_end >= next_start do
      [[head_start, max(head_end, next_end)] | tail]
    else
      [next | acc]
    end
  end

  defp distress_point(state) do
    1..@max_size
    |> Enum.find_value(&uncovered_at_y(&1, state))
  end

  defp uncovered_at_y(y, state) do
    x =
      state.sensors
      |> Enum.map(&get_impossible_range(&1, y))
      |> Enum.reject(&is_nil/1)
      |> merge_intervals()
      |> uncovered_at_x(-1)

    if x !== nil and x <= @max_size do
      {x, y}
    end
  end

  defp uncovered_at_x([], _), do: nil

  defp uncovered_at_x([[l, r] | tail], last_x) do
    if last_x + 1 < l do
      last_x + 1
    else
      uncovered_at_x(tail, max(r, last_x))
    end
  end

  defp tuning_signal({x, y}), do: x * @max_size + y
end

IO.puts("Solve 1: #{Day15.solve_1()}")
IO.puts("Solve 2: #{Day15.solve_2()}")
