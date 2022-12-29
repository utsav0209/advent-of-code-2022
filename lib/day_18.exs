defmodule Day18 do
  @infinity 1_000_000_000

  defp read_input() do
    File.read!("lib/inputs/day_18.input")
    |> to_string()
  end

  def solve_1() do
    read_input()
    |> parse_cubes()
    |> get_surface_area()
  end

  def solve_2() do
    read_input()
    |> parse_cubes()
    |> get_exterior_surface_area()
  end

  defp parse_cubes(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn cube_str ->
      String.split(cube_str, ",", trim: true) |> Enum.map(&String.to_integer/1)
    end)
  end

  defp get_surface_area(cubes) do
    cubes_map_set = MapSet.new(cubes)

    cubes
    |> Enum.map(&touching_cubes(cubes_map_set, &1))
    |> Enum.map(fn touching -> 6 - touching end)
    |> Enum.sum()
  end

  defp get_exterior_surface_area(cubes) do
    cubes_map_set = MapSet.new(cubes)
    limits = get_cube_limits(cubes)

    {total_external_area, _, _} =
      Enum.reduce(
        cubes,
        {0, %MapSet{}, %MapSet{}},
        fn cube, {total_external_area, external_cubes, internal_cubes} ->
          {cube_external_surfaces, external_cubes, internal_cubes} =
            Enum.reduce(
              get_neighbors(cube),
              {0, external_cubes, internal_cubes},
              fn neighbor, {external_surfaces, acc_external_cubes, acc_internal_cubes} ->
                {has_path, _, _} =
                  has_path_to_external?(
                    [neighbor],
                    acc_external_cubes,
                    acc_internal_cubes,
                    cubes_map_set,
                    MapSet.new([neighbor]),
                    limits
                  )

                if has_path,
                  do: {
                    external_surfaces + 1,
                    MapSet.put(acc_external_cubes, neighbor),
                    acc_internal_cubes
                  },
                  else: {
                    external_surfaces,
                    acc_external_cubes,
                    MapSet.put(acc_internal_cubes, neighbor)
                  }
              end
            )

          {total_external_area + cube_external_surfaces, external_cubes, internal_cubes}
        end
      )

    total_external_area
  end

  defp get_cube_limits(cubes) do
    limits = %{
      minX: @infinity,
      maxX: -@infinity,
      minY: @infinity,
      maxY: -@infinity,
      minZ: @infinity,
      maxZ: -@infinity
    }

    Enum.reduce(cubes, limits, fn [x, y, z], acc ->
      %{
        minX: min(acc[:minX], x),
        maxX: max(acc[:maxX], x),
        minY: min(acc[:minY], y),
        maxY: max(acc[:maxY], y),
        minZ: min(acc[:minZ], z),
        maxZ: max(acc[:maxZ], z)
      }
    end)
  end

  defp touching_cubes(cubes, cube) do
    MapSet.intersection(cubes, get_neighbors(cube))
    |> MapSet.size()
  end

  defp get_neighbors([x, y, z]) do
    [
      [x + 1, y, z],
      [x - 1, y, z],
      [x, y + 1, z],
      [x, y - 1, z],
      [x, y, z + 1],
      [x, y, z - 1]
    ]
    |> MapSet.new()
  end

  defp has_path_to_external?([], external_cubes, internal_cubes, _, _, _) do
    {false, external_cubes, internal_cubes}
  end

  defp has_path_to_external?(
         [cube | other_cubes] = cubess,
         external_cubes,
         internal_cubes,
         lava_cubes,
         explored,
         limits
       ) do
    # IO.inspect(length(cubess))
    # IO.inspect(length(Enum.uniq(cubess)))
    # IO.inspect(MapSet.size(explored))

    cond do
      MapSet.member?(external_cubes, cube) ->
        {true, external_cubes, internal_cubes}

      MapSet.member?(internal_cubes, cube) ->
        has_path_to_external?(
          other_cubes,
          external_cubes,
          internal_cubes,
          lava_cubes,
          explored,
          limits
        )

      MapSet.member?(lava_cubes, cube) ->
        has_path_to_external?(
          other_cubes,
          external_cubes,
          internal_cubes,
          lava_cubes,
          explored,
          limits
        )

      beyond_limits?(cube, limits) ->
        {true, external_cubes, internal_cubes}

      true ->
        get_neighbors(cube)
        |> Enum.filter(fn neighbor -> not MapSet.member?(explored, neighbor) end)
        |> then(fn neighbor_cubes ->
          has_path_to_external?(
            other_cubes ++ neighbor_cubes,
            external_cubes,
            internal_cubes,
            lava_cubes,
            MapSet.union(explored, MapSet.new(neighbor_cubes)),
            limits
          )
        end)
    end
  end

  defp beyond_limits?([x, y, z], limits) do
    x < limits[:minX] or x > limits[:maxX] or
      y < limits[:minY] or y > limits[:maxY] or
      z < limits[:minZ] or z > limits[:maxZ]
  end
end

IO.puts("Solve 1: #{Day18.solve_1()}")
IO.puts("Solve 2: #{Day18.solve_2()}")
