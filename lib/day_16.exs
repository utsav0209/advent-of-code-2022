defmodule Valve do
  defstruct name: '', flow: 0, neighbors: []
end

defmodule Day16 do
  @infinity 1_000_000_000_000

  defp read_input() do
    File.read!("lib/inputs/day_16.input")
    |> to_string()
  end

  def solve_1() do
    {graph, distances, openable_valves} =
      read_input()
      |> parse_input()

    {score, _} =
      get_max_pressure_release(
        30,
        Map.get(graph, "AA"),
        openable_valves,
        graph,
        distances,
        false,
        %{}
      )

    score
  end

  def solve_2() do
    {graph, distances, openable_valves} =
      read_input()
      |> parse_input()

    {score, _} =
      get_max_pressure_release(
        26,
        Map.get(graph, "AA"),
        openable_valves,
        graph,
        distances,
        true,
        %{}
      )

    score
  end

  defp parse_input(input) do
    graph =
      input
      |> String.split("\n")
      |> Enum.reduce(%{}, &parse_valve/2)

    distances = get_distances(Map.values(graph))

    openable_valves =
      Map.values(graph) |> Enum.filter(fn v -> v.name !== "AA" and v.flow !== 0 end)

    {graph, distances, openable_valves}
  end

  defp parse_valve(valve_str, graph) do
    ["Valve " <> valve, neighbors] = String.split(valve_str, ";")

    [name, flow] = String.split(valve, " has flow rate=")

    neighbors =
      cond do
        String.starts_with?(neighbors, " tunnels") ->
          " tunnels lead to valves " <> neighbors = neighbors

          neighbors
          |> String.split(", ")

        true ->
          " tunnel leads to valve " <> neighbors = neighbors

          neighbors
          |> String.split(", ")
      end

    Map.put(graph, name, %Valve{name: name, flow: String.to_integer(flow), neighbors: neighbors})
  end

  defp get_distances(valves) do
    default_distances = valves |> Enum.map(fn v -> {v.name, @infinity} end) |> Map.new()

    valves
    |> Enum.reduce(%{}, &valve_neighbor_distances(&1, &2, default_distances))
    |> get_shortest_distances(valves)
  end

  defp valve_neighbor_distances(valve, distances, valve_distances) do
    valve.neighbors
    |> Enum.reduce(valve_distances, fn neighbor, acc -> Map.put(acc, neighbor, 1) end)
    |> Map.put(valve.name, 0)
    |> then(fn vd -> Map.put(distances, valve.name, vd) end)
  end

  defp get_shortest_distances(distances, valves) do
    Enum.reduce(valves, distances, fn v1, acc1 ->
      Enum.reduce(valves, acc1, fn v2, acc2 ->
        Enum.reduce(valves, acc2, fn v3, acc3 ->
          v2_map =
            Map.put(
              acc3[v2.name],
              v3.name,
              min(
                acc3[v2.name][v3.name],
                acc3[v2.name][v1.name] + acc3[v1.name][v3.name]
              )
            )

          Map.put(acc3, v2.name, v2_map)
        end)
      end)
    end)
  end

  defp get_max_pressure_release(
         time_left,
         _current_valve,
         _unopened_valves,
         _graph,
         _distances,
         _is_elephant_trained,
         cache
       )
       when time_left <= 0,
       do: {0, cache}

  defp get_max_pressure_release(
         time_left,
         current_valve,
         unopened_valves,
         graph,
         distances,
         is_elephant_trained,
         cache
       ) do
    if(Map.has_key?(cache, {time_left, current_valve, unopened_valves, is_elephant_trained})) do
      {Map.get(cache, {time_left, current_valve, unopened_valves, is_elephant_trained}), cache}
    else
      {initial_score, initial_cache} =
        case is_elephant_trained do
          true ->
            get_max_pressure_release(
              26,
              graph["AA"],
              unopened_valves,
              graph,
              distances,
              false,
              cache
            )

          false ->
            {0, cache}
        end

      {score, new_cache} =
        Enum.reduce(unopened_valves, {initial_score, initial_cache}, fn next_to_open,
                                                                        {score, acc_cache} ->
          new_time_left = time_left - distances[current_valve.name][next_to_open.name] - 1
          new_unopened = Enum.filter(unopened_valves, fn v -> v.name !== next_to_open.name end)

          {next_score, next_cache} =
            get_max_pressure_release(
              new_time_left,
              next_to_open,
              new_unopened,
              graph,
              distances,
              is_elephant_trained,
              acc_cache
            )

          {max(score, next_to_open.flow * new_time_left + next_score), next_cache}
        end)

      {
        score,
        Map.put(
          new_cache,
          {time_left, current_valve, unopened_valves, is_elephant_trained},
          score
        )
      }
    end
  end
end

IO.puts("Solve 1: #{Day16.solve_1()}")
IO.puts("Solve 2: #{Day16.solve_2()}")
