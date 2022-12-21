defmodule Day8 do
  @directions [:left, :right, :top, :bottom]

  defp get_elements_in_direction(data, index_r, index_c, direction) do
    case direction do
      :left ->
        data
        |> Enum.at(index_r)
        |> Enum.take(index_c)
        |> Enum.reverse()

      :right ->
        data
        |> Enum.at(index_r)
        |> Enum.drop(index_c + 1)

      :top ->
        data
        |> Enum.take(index_r)
        |> Enum.map(fn row -> Enum.at(row, index_c) end)
        |> List.flatten()
        |> Enum.reverse()

      :bottom ->
        data
        |> Enum.drop(index_r + 1)
        |> Enum.map(fn row -> Enum.at(row, index_c) end)
        |> List.flatten()
    end
  end

  defp is_visible(height, data, index_r, index_c) do
    @directions
    |> Enum.find(fn direction ->
      data
      |> get_elements_in_direction(index_r, index_c, direction)
      |> Enum.max()
      |> Kernel.<(height)
    end)
  end

  defp is_tree_visible(_height, _index_r, index_c, _data, _n_r, n_c)
       when index_c == 0 or index_c == n_c - 1,
       do: true

  defp is_tree_visible(height, index_r, index_c, data, _n_r, _n_c),
    do: is_visible(height, data, index_r, index_c)

  defp process_row_for_visibility(_row, index, _data, n) when index == 0 or index == n - 1,
    do: List.duplicate(true, n)

  defp process_row_for_visibility(row, index_r, data, n),
    do:
      row
      |> Enum.with_index()
      |> then(fn r ->
        Enum.map(r, fn {height, index_c} ->
          is_tree_visible(height, index_r, index_c, data, n, length(row))
        end)
      end)

  defp find_first_greater_or_equal_height(heights, height) do
    case(Enum.find_index(heights, fn h -> h >= height end)) do
      nil ->
        length(heights)

      index ->
        index + 1
    end
  end

  defp calculate_scenic_score(height, index_r, index_c, data),
    do:
      @directions
      |> Enum.reduce(1, fn direction, acc ->
        data
        |> get_elements_in_direction(index_r, index_c, direction)
        |> find_first_greater_or_equal_height(height)
        |> Kernel.*(acc)
      end)

  defp process_row_and_calculate_scenic_score(row, index_r, data),
    do:
      row
      |> Enum.with_index()
      |> then(fn r ->
        Enum.map(r, fn {height, index_c} ->
          calculate_scenic_score(height, index_r, index_c, data)
        end)
      end)

  defp read_input() do
    File.stream!("lib/inputs/day_8.input", [:read])
    |> Stream.map(fn str -> String.trim_trailing(str, "\n") end)
    |> Enum.to_list()
    |> Enum.map(fn row -> String.graphemes(row) |> Enum.map(&String.to_integer/1) end)
  end

  def solve_1() do
    read_input()
    |> then(fn data ->
      Enum.with_index(data)
      |> Enum.map(fn {row, index} ->
        process_row_for_visibility(row, index, data, length(data))
      end)
    end)
    |> Enum.map(fn row -> Enum.filter(row, fn col -> col end) |> length() end)
    |> Enum.sum()
  end

  def solve_2() do
    read_input()
    |> then(fn data ->
      Enum.with_index(data)
      |> Enum.map(fn {row, index} ->
        process_row_and_calculate_scenic_score(row, index, data)
      end)
    end)
    |> List.flatten()
    |> Enum.max()
  end
end

IO.puts("Solve 1: #{Day8.solve_1()}")
IO.puts("Solve 2: #{Day8.solve_2()}")
