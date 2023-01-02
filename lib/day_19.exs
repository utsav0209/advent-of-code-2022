defmodule Day19 do
  defp read_input() do
    File.read!("lib/inputs/day_19.input")
    |> to_string()
  end

  def solve_1() do
    read_input()
    |> parse_blueprints()
    |> process_maximum_geodes(24)
    |> Enum.map(fn {id, geodes} -> id * geodes end)
    |> Enum.sum()
  end

  def solve_2() do
    read_input()
    |> parse_blueprints()
    |> Enum.take(3)
    |> process_maximum_geodes(32)
    |> Enum.map(&elem(&1, 1))
    |> Enum.product()
  end

  defp parse_blueprints(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&create_blue_print/1)
  end

  defp create_blue_print(blueprint) do
    [
      id,
      ore_robot_cost,
      clay_robot_cost,
      obsidian_robot_ore_cost,
      obsidian_robot_clay_cost,
      geode_ore_cost,
      geode_obsidian_cost
    ] =
      blueprint
      |> String.replace(~r/[^\d]/, " ")
      |> String.split()
      |> Enum.map(&String.to_integer/1)

    {
      id,
      %{
        ore: %{ore: ore_robot_cost},
        clay: %{ore: clay_robot_cost},
        obsidian: %{ore: obsidian_robot_ore_cost, clay: obsidian_robot_clay_cost},
        geode: %{ore: geode_ore_cost, obsidian: geode_obsidian_cost}
      }
    }
  end

  defp process_maximum_geodes(blueprints, max_time) do
    base_state = %{
      minute: 1,
      max_time: max_time,
      blueprint: nil,
      materials: %{
        ore: 1,
        clay: 0,
        obsidian: 0,
        geode: 0
      },
      collectors: %{
        ore: 1,
        clay: 0,
        obsidian: 0,
        geode: 0
      }
    }

    blueprints
    |> Enum.map(fn {id, blueprint} ->
      Process.put(:max_geodes, 0)

      next_states(%{base_state | blueprint: blueprint})
      |> Enum.map(fn s -> s[:materials][:geode] end)
      |> Enum.max()
      |> then(&{id, &1})
    end)
  end

  defp next_states(state = %{minute: m, max_time: max_time}) when m >= max_time do
    Process.put(:max_geodes, max(Process.get(:max_geodes, 0), state[:materials][:geode]))
    [state]
  end

  defp next_states(state) do
    [:ore, :clay, :obsidian, :geode]
    |> Enum.reduce([], &add_next_state(&1, &2, state))
    |> Enum.reject(&(max_obtainable_score(&1) < Process.get(:max_geodes, 0)))
    |> Enum.flat_map(&next_states/1)
  end

  defp add_next_state(type, list, state) do
    if collector_possible?(type, state) and collector_useful?(type, state) do
      [add_collector(type, state) | list]
    else
      list
    end
  end

  defp collector_possible?(:obsidian, %{collectors: %{clay: cc}}), do: cc > 0
  defp collector_possible?(:geode, %{collectors: %{obsidian: oc}}), do: oc > 0
  defp collector_possible?(_, _), do: true

  defp collector_useful?(:ore, %{collectors: %{ore: oc}, blueprint: blueprint}) do
    max_ore_cost = blueprint |> Enum.map(fn {_, %{ore: o}} -> o end) |> Enum.max()
    oc < max_ore_cost
  end

  defp collector_useful?(:clay, %{collectors: %{clay: cc}, blueprint: blueprint}) do
    cc < blueprint[:obsidian][:clay]
  end

  defp collector_useful?(:obsidian, %{collectors: %{obsidian: oc}, blueprint: blueprint}) do
    oc < blueprint[:geode][:obsidian]
  end

  defp collector_useful?(:geode, _), do: true

  defp add_collector(type, state) do
    turns_required(type, state) |> take_turns(state) |> build_collector(type)
  end

  defp turns_required(type, %{blueprint: blueprint} = state) do
    blueprint[type]
    |> Map.keys()
    |> Enum.map(fn k -> {k, max(0, blueprint[type][k] - state[:materials][k])} end)
    |> Enum.map(fn {t, req} -> (req / state[:collectors][t]) |> Float.ceil() |> trunc() end)
    |> Enum.max()
    |> Kernel.+(1)
  end

  defp take_turns(turns, %{minute: m, max_time: mt} = state) when m + turns > mt do
    take_turns(mt - m, state)
  end

  defp take_turns(turns, state = %{minute: m, materials: materials, collectors: collectors}) do
    new_materials =
      collectors
      |> Map.new(fn {type, amount} -> {type, amount * turns} end)
      |> Map.merge(materials, fn _, g, o -> g + o end)

    %{state | minute: m + turns, materials: new_materials}
  end

  defp build_collector(
         state = %{materials: materials, collectors: collectors, blueprint: blueprint},
         type
       ) do
    collectors = Map.update!(collectors, type, &(&1 + 1))
    materials = Map.merge(materials, blueprint[type], fn _, o, c -> o - c end)
    %{state | collectors: collectors, materials: materials}
  end

  defp max_obtainable_score(state) do
    remaining = state[:max_time] - state[:minute]
    triangular = div(remaining * (remaining + 1), 2)
    state[:materials][:geode] + remaining * state[:collectors][:geode] + triangular
  end
end

IO.puts("Solve 1: #{Day19.solve_1()}")
IO.puts("Solve 2: #{Day19.solve_2()}")
