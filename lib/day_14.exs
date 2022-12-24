defmodule Day14 do
  @sand_start_loc {500, 0}

  defp read_input() do
    File.read!("lib/inputs/day_14.input")
    |> to_string()
  end

  def solve_1() do
    read_input()
    |> parse_rocks()
    |> create_terrain()
    |> Map.put(:has_bottom, false)
    |> trace_sand()
    |> Map.values()
    |> Enum.filter(fn x -> x == "o" end)
    |> length()
  end

  def solve_2() do
    read_input()
    |> parse_rocks()
    |> create_terrain()
    |> Map.put(:has_bottom, true)
    |> trace_sand()
    |> Map.values()
    |> Enum.filter(fn x -> x == "o" end)
    |> length()
  end

  defp parse_rocks(rocks_str) do
    rocks_str
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_rock/1)
  end

  defp parse_rock(rock_str) do
    rock_str
    |> String.split(" -> ", trim: true)
    |> Enum.map(fn rock_pos ->
      String.split(rock_pos, ",", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
  end

  defp create_terrain(rocks_positions),
    do:
      rocks_positions
      |> Enum.reduce(%{}, &trace_rock_on_terrain/2)

  defp trace_rock_on_terrain({{x1, y1}, {x2, y2}}, terrain) when x1 == x2,
    do:
      Enum.reduce(y1..y2, terrain, fn y, acc ->
        Map.put(acc, {x1, y}, "#")
      end)

  defp trace_rock_on_terrain({{x1, y1}, {x2, y2}}, terrain) when y1 == y2,
    do:
      Enum.reduce(x1..x2, terrain, fn x, acc ->
        Map.put(acc, {x, y1}, "#")
      end)

  defp trace_rock_on_terrain(rock_outline, terrain),
    do:
      Enum.zip(rock_outline, tl(rock_outline))
      |> Enum.reduce(terrain, &trace_rock_on_terrain/2)

  defp get_terrain_limits(terrain) do
    outlines = Map.keys(terrain) |> Enum.filter(fn x -> x !== :has_bottom end)

    x_locs = outlines |> Enum.map(fn {x, _} -> x end)
    y_locs = outlines |> Enum.map(fn {_, y} -> y end)

    x_limits = {Enum.min(x_locs), Enum.max(x_locs)}
    y_limits = {0, Enum.max(y_locs)}

    {x_limits, y_limits}
  end

  defp is_going_into_void?({{x_min, x_max}, {y_min, y_max}}, {x, y}),
    do: x < x_min or x > x_max or y < y_min or y > y_max

  defp can_move(terrain, {x, y}), do: !Map.has_key?(terrain, {x, y})

  defp trace_sand(terrain) do
    limits = get_terrain_limits(terrain)
    trace_sand(terrain, limits, @sand_start_loc)
  end

  defp trace_sand(terrain, {_, {_, y_max}} = limits, {x, y} = sand_loc) do
    cond do
      !terrain[:has_bottom] and is_going_into_void?(limits, sand_loc) ->
        terrain

      terrain[:has_bottom] and y + 1 == y_max + 2 ->
        terrain = Map.put(terrain, {x, y}, "o")
        trace_sand(terrain, limits, @sand_start_loc)

      can_move(terrain, {x, y + 1}) ->
        trace_sand(terrain, limits, {x, y + 1})

      can_move(terrain, {x - 1, y + 1}) ->
        trace_sand(terrain, limits, {x - 1, y + 1})

      can_move(terrain, {x + 1, y + 1}) ->
        trace_sand(terrain, limits, {x + 1, y + 1})

      true ->
        terrain = Map.put(terrain, {x, y}, "o")

        if terrain[:has_bottom] and {x, y} == {500, 0} do
          terrain
        else
          trace_sand(terrain, limits, @sand_start_loc)
        end
    end
  end
end

IO.puts("Solve 1: #{Day14.solve_1()}")
IO.puts("Solve 2: #{Day14.solve_2()}")
