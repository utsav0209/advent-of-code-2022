defmodule Day12 do
  defp read_input() do
    File.stream!("lib/inputs/day_12.input", [:read])
    |> Stream.map(fn str -> String.trim_trailing(str, "\n") end)
    |> Enum.to_list()
  end

  def solve_1() do
    state = %{elevations: %{}, distances: %{}, end: nil, bfs: []}

    read_input()
    |> Enum.with_index()
    |> Enum.reduce(state, &parse_row/2)
    |> fill_distances(1)
    |> get_end_distance()
  end

  def solve_2() do
    state = %{elevations: %{}, distances: %{}, end: nil, bfs: []}

    read_input()
    |> Enum.with_index()
    |> Enum.reduce(state, &parse_row(&1, &2, true))
    |> fill_distances(1)
    |> get_end_distance()
  end

  defp parse_row({row, y}, state, a_as_start \\ false) do
    row
    |> String.to_charlist()
    |> Enum.map(&parse_cell(&1, a_as_start))
    |> Enum.with_index()
    |> Enum.reduce(state, &add_cell(&1, &2, y))
  end

  defp parse_cell(cell, a_as_start) do
    point = %{start: false, end: false, elevation: -1}

    cond do
      cell == hd('S') ->
        %{point | start: true, elevation: 0}

      cell == hd('a') ->
        %{point | start: a_as_start, elevation: 0}

      cell == hd('E') ->
        %{point | end: true, elevation: 25}

      true ->
        %{point | elevation: cell - hd('a')}
    end
  end

  defp add_cell({cell, x}, state, y) do
    point = {x, y}

    state =
      cond do
        cell.start ->
          %{state | bfs: state.bfs ++ [point]}
          |> set_distance(point, 0)
          |> set_elevation(point, cell.elevation)

        cell.end ->
          %{state | end: point}
          |> set_elevation(point, cell.elevation)

        true ->
          state
          |> set_elevation(point, cell.elevation)
      end

    state
  end

  defp set_distance(state, point, distance) do
    %{state | distances: Map.put(state.distances, point, distance)}
  end

  defp set_distances(points, state, distance) do
    points
    |> Enum.reduce(state, &set_distance(&2, &1, distance))
    |> Map.put(:bfs, points)
  end

  defp set_elevation(state, point, elevation) do
    %{state | elevations: Map.put(state.elevations, point, elevation)}
  end

  defp fill_distances(%{bfs: []} = state, _distance), do: state

  defp fill_distances(state, distance) do
    state.bfs
    |> Enum.map(&get_neighbors(&1, state))
    |> List.flatten()
    |> Enum.uniq()
    |> set_distances(state, distance)
    |> fill_distances(distance + 1)
  end

  defp get_neighbors(point, state) do
    point
    |> neighbors()
    |> Enum.filter(fn neighbor -> state.distances[neighbor] == nil end)
    |> Enum.filter(fn neighbor -> state.elevations[neighbor] <= state.elevations[point] + 1 end)
  end

  defp neighbors({x, y}) do
    [
      {x + 1, y},
      {x - 1, y},
      {x, y + 1},
      {x, y - 1}
    ]
  end

  defp get_end_distance(state) do
    state.distances[state.end]
  end
end

IO.puts("Solve 1: #{Day12.solve_1()}")
IO.puts("Solve 2: #{Day12.solve_2()}")
