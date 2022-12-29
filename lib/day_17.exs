defmodule Day17 do
  @target_rocks_1 2022
  @target_rocks_2 1_000_000_000_000
  @rocks [
    [{0, 0}, {1, 0}, {2, 0}, {3, 0}],
    [{1, 0}, {0, 1}, {1, 1}, {2, 1}, {1, 2}],
    [{0, 0}, {1, 0}, {2, 0}, {2, 1}, {2, 2}],
    [{0, 0}, {0, 1}, {0, 2}, {0, 3}],
    [{0, 0}, {1, 0}, {0, 1}, {1, 1}]
  ]

  defp read_input() do
    File.read!("lib/inputs/day_17.input")
    |> to_string()
  end

  def solve_1() do
    read_input()
    |> parse_jet_pushes()
    |> get_tower_height(@target_rocks_1)
  end

  def solve_2() do
    read_input()
    |> parse_jet_pushes()
    |> get_tower_height(@target_rocks_2)
  end

  defp parse_jet_pushes(input) do
    input
    |> String.split("", trim: true)
    |> Enum.with_index()
    |> Enum.map(fn {push, index} ->
      case push do
        "<" ->
          {:left, index}

        ">" ->
          {:right, index}
      end
    end)
  end

  defp get_tower_height(jets, target_rocks) do
    case find_loop(jets, target_rocks) do
      {period_start, period_end, jets, tower, base_height, height} ->
        period_length = period_end - period_start + 1
        number_of_periods = div(target_rocks - period_start - 1, period_length)

        remaining_start = period_start + period_length * number_of_periods

        {_, _, rest_height} =
          Enum.reduce(remaining_start..target_rocks, {jets, tower, height}, &make_rock_fall/2)

        (height - base_height) * (number_of_periods - 1) + rest_height

      {_, _, height, _} ->
        height
    end
  end

  defp find_loop(jets, target_rocks) do
    tower = 0..6 |> Enum.map(fn x -> {x, 0} end) |> MapSet.new()

    Enum.reduce_while(
      1..target_rocks,
      {jets, tower, 0, %{}},
      fn rock, {jets, tower, height, seen} ->
        {_, jet_index} = hd(jets)
        key = {rem(rock, length(@rocks)), jet_index}

        if(Map.has_key?(seen, key)) do
          case Map.get(seen, key) do
            {_, _, :first} ->
              {new_jets, new_tower, new_height} = make_rock_fall(rock, {jets, tower, height})

              {
                :cont,
                {new_jets, new_tower, new_height, Map.put(seen, key, {rock, height, :second})}
              }

            {start, base_height, :second} ->
              {:halt, {start, rock - 1, jets, tower, base_height, height}}
          end
        else
          {new_jets, new_tower, new_height} = make_rock_fall(rock, {jets, tower, height})
          {:cont, {new_jets, new_tower, new_height, Map.put(seen, key, {rock, height, :first})}}
        end
      end
    )
  end

  defp make_rock_fall(round, {jets, tower, height}) do
    {jets, rock} =
      Stream.cycle([nil])
      |> Enum.reduce_while({jets, get_a_rock(round, height + 4)}, fn _, {jets, rock} ->
        [{jet_push, _} = current_jet | rest_jets] = jets
        blown_rock = blow_rock(rock, jet_push, tower)
        fallen_rock = fall_rock(blown_rock)

        next_jets = rest_jets ++ [current_jet]

        if touching?(tower, fallen_rock),
          do: {:halt, {next_jets, blown_rock}},
          else: {:cont, {next_jets, fallen_rock}}
      end)

    {jets, add_rock_to_tower(tower, rock), tower_height(height, rock)}
  end

  defp make_rock_fall(round, {jets, tower, height, true}) do
    {jets, rock} =
      Stream.cycle([nil])
      |> Enum.reduce_while({jets, get_a_rock(round, height + 4)}, fn _, {jets, rock} ->
        [{jet_push, _} = current_jet | rest_jets] = jets
        blown_rock = blow_rock(rock, jet_push, tower)
        fallen_rock = fall_rock(blown_rock)

        next_jets = rest_jets ++ [current_jet]

        if touching?(tower, fallen_rock),
          do: {:halt, {next_jets, blown_rock}},
          else: {:cont, {next_jets, fallen_rock}}
      end)

    {jets, add_rock_to_tower(tower, rock), tower_height(height, rock)}
  end

  defp get_a_rock(round, dy) do
    rock_index = rem(round - 1, length(@rocks))

    Enum.at(@rocks, rock_index)
    |> Enum.map(fn {x, y} -> {x + 2, y + dy} end)
  end

  defp blow_rock(rock, :left, tower) do
    if Enum.any?(rock, fn {x, _} -> x <= 0 end),
      do: rock,
      else: Enum.map(rock, fn {x, y} -> {x - 1, y} end) |> avoid_collision(tower, rock)
  end

  defp blow_rock(rock, :right, tower) do
    if Enum.any?(rock, fn {x, _} -> x >= 6 end),
      do: rock,
      else: Enum.map(rock, fn {x, y} -> {x + 1, y} end) |> avoid_collision(tower, rock)
  end

  defp avoid_collision(new_rock, tower, original_rock) do
    if(MapSet.disjoint?(tower, MapSet.new(new_rock)),
      do: new_rock,
      else: original_rock
    )
  end

  defp fall_rock(rock), do: Enum.map(rock, fn {x, y} -> {x, y - 1} end)

  defp touching?(tower, rock), do: not MapSet.disjoint?(tower, MapSet.new(rock))

  defp add_rock_to_tower(tower, rock), do: MapSet.union(tower, MapSet.new(rock))

  defp tower_height(height, rock),
    do: max(height, rock |> Enum.map(fn {_, y} -> y end) |> Enum.max())
end

IO.puts("Solve 1: #{Day17.solve_1()}")
IO.puts("Solve 2: #{Day17.solve_2()}")
