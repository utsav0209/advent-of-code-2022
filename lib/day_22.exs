defmodule Day22 do
  defp read_input() do
    File.read!("lib/inputs/day_22.input")
    |> to_string()
  end

  def solve_1() do
    {board, moves} = read_input() |> parse_input()

    board = make_moves(board, moves)
    {x, y} = board[:pos]

    1000 * x + 4 * y + facing(board[:direction])
  end

  def solve_2() do
    {board, moves} = read_input() |> parse_input()

    board = cubic_moves(board, moves)
    {x, y} = board[:pos]

    1000 * x + 4 * y + facing(board[:direction])
  end

  defp parse_input(board_str) do
    [board_str, move_str] = String.split(board_str, "\n\n", trim: true)

    {parse_board(board_str), parse_moves(move_str)}
  end

  defp parse_board(board_str) do
    board =
      board_str
      |> String.split("\n", trim: true)
      |> Enum.with_index(1)
      |> Enum.reduce(
        %{board: %{}, start_location: {-1, -1}},
        fn {row, row_index}, board ->
          parse_row(row_index, row, board)
        end
      )

    %{
      tiles: board,
      pos: board_start_pos(board_str),
      direction: :right,
      max_width: get_max_width(board_str),
      max_height: get_max_height(board_str)
    }
  end

  defp parse_row(row_index, row_str, board) do
    row_str
    |> String.graphemes()
    |> Enum.with_index(1)
    |> Enum.reduce(board, fn {col, col_index}, acc_board ->
      Map.put(
        acc_board,
        {row_index, col_index},
        %{
          is_wall: col == "#",
          is_tile: col == ".",
          is_void: col == " "
        }
      )
    end)
  end

  defp board_start_pos(board_str) do
    y_pos =
      board_str
      |> String.split("\n", trim: true)
      |> Enum.at(0)
      |> String.graphemes()
      |> Enum.find_index(fn x -> x == "." end)

    {1, y_pos + 1}
  end

  defp parse_moves(move_str) do
    String.split(move_str, ~r/(L|R)/, trim: true, include_captures: true)
    |> Enum.map(fn x -> if x in ["L", "R"], do: x, else: String.to_integer(x) end)
  end

  defp get_max_width(board_str) do
    board_str
    |> String.split("\n")
    |> Enum.map(fn str -> String.length(str) end)
    |> Enum.max()
  end

  defp get_max_height(board_str) do
    board_str
    |> String.split("\n")
    |> length()
  end

  defp facing(:right), do: 0
  defp facing(:down), do: 1
  defp facing(:up), do: 2
  defp facing(:left), do: 3

  defp change_dir(:left, "L"), do: :down
  defp change_dir(:left, "R"), do: :up
  defp change_dir(:right, "L"), do: :up
  defp change_dir(:right, "R"), do: :down
  defp change_dir(:up, "L"), do: :left
  defp change_dir(:up, "R"), do: :right
  defp change_dir(:down, "L"), do: :right
  defp change_dir(:down, "R"), do: :left

  defp make_moves(board, []), do: board

  defp make_moves(board, [direction | rest_moves]) when direction in ["L", "R"] do
    make_moves(%{board | direction: change_dir(board[:direction], direction)}, rest_moves)
  end

  defp make_moves(board, [move_by | rest_moves]) do
    next_pos = get_next_pos(board, board[:pos], move_by)

    make_moves(%{board | pos: next_pos}, rest_moves)
  end

  defp next_location({r, c}, :left), do: {r, c - 1}
  defp next_location({r, c}, :right), do: {r, c + 1}
  defp next_location({r, c}, :up), do: {r - 1, c}
  defp next_location({r, c}, :down), do: {r + 1, c}

  defp next_location({r, c}, max_r, _) when r <= 0, do: {max_r, c}
  defp next_location({r, c}, _, max_c) when c <= 0, do: {r, max_c}
  defp next_location({r, c}, max_r, _) when r > max_r, do: {0, c}
  defp next_location({r, c}, _, max_c) when c > max_c, do: {r, 0}
  defp next_location({r, c}, _, _), do: {r, c}

  defp get_next_pos(_, curr_pos, 0), do: curr_pos

  defp get_next_pos(board, curr_pos, moves) do
    new_pos =
      curr_pos
      |> next_location(board[:direction])
      |> next_location(board[:max_height], board[:max_width])

    new_pos =
      Stream.cycle([nil])
      |> Enum.reduce_while(new_pos, fn _, acc_pos ->
        case Map.get(board[:tiles], acc_pos, %{is_void: true}) do
          %{is_void: true} ->
            {:cont,
             next_location(acc_pos, board[:direction])
             |> next_location(board[:max_height], board[:max_width])}

          _ ->
            {:halt, acc_pos}
        end
      end)

    case Map.get(board[:tiles], new_pos, %{is_void: true}) do
      %{is_wall: true} ->
        curr_pos

      _ ->
        get_next_pos(board, new_pos, moves - 1)
    end
  end

  defp cubic_moves(board, []), do: board

  defp cubic_moves(board, [direction | rest_moves]) when direction in ["L", "R"] do
    cubic_moves(%{board | direction: change_dir(board[:direction], direction)}, rest_moves)
  end

  defp cubic_moves(board, [0 | rest_moves]), do: cubic_moves(board, rest_moves)

  defp cubic_moves(board, [move_by | rest_moves]) do
    new_pos = next_location(board[:pos], board[:direction])

    {new_pos, new_direction} =
      case Map.get(board[:tiles], new_pos, %{is_void: true}) do
        %{is_void: true} ->
          cube_wrap(board)

        _ ->
          {new_pos, board[:direction]}
      end

    case Map.get(board[:tiles], new_pos, %{is_void: true}) do
      %{is_wall: true} ->
        cubic_moves(board, rest_moves)

      %{is_tile: true} ->
        cubic_moves(%{board | pos: new_pos, direction: new_direction}, [
          move_by - 1 | rest_moves
        ])
    end
  end

  defp cube_wrap(board) do
    {curr_r, curr_c} = board[:pos]
    facing = board[:direction]

    rel_r = Integer.mod(curr_r - 1, 50) + 1
    rel_c = Integer.mod(curr_c - 1, 50) + 1

    r_wrap = div(curr_r - 1, 50)
    c_wrap = div(curr_c - 1, 50)

    [next_pos, next_facing] =
      cond do
        # Up
        facing == :up and r_wrap == 0 and c_wrap == 1 ->
          [{150 + rel_c, 1}, :right]

        facing == :up and r_wrap == 0 and c_wrap == 2 ->
          [{200, rel_c}, :up]

        facing == :up and r_wrap == 2 and c_wrap == 0 ->
          [{50 + rel_c, 51}, :right]

        # down
        facing == :down and r_wrap == 0 and c_wrap == 2 ->
          [{50 + rel_c, 100}, :left]

        facing == :down and r_wrap == 2 and c_wrap == 1 ->
          [{150 + rel_c, 50}, :left]

        facing == :down and r_wrap == 3 and c_wrap == 0 ->
          [{1, 100 + rel_c}, :down]

        # left
        facing == :left and r_wrap == 0 and c_wrap == 1 ->
          [{151 - rel_r, 1}, :right]

        facing == :left and r_wrap == 1 and c_wrap == 1 ->
          [{101, rel_r}, :down]

        facing == :left and r_wrap == 2 and c_wrap == 0 ->
          [{51 - rel_r, 51}, :right]

        facing == :left and r_wrap == 3 and c_wrap == 0 ->
          [{1, 50 + rel_r}, :down]

        # right
        facing == :right and r_wrap == 0 and c_wrap == 2 ->
          [{151 - rel_r, 100}, :left]

        facing == :right and r_wrap == 1 and c_wrap == 1 ->
          [{50, 100 + rel_r}, :up]

        facing == :right and r_wrap == 2 and c_wrap == 1 ->
          [{51 - rel_r, 100}, :left]

        facing == :right and r_wrap == 3 and c_wrap == 0 ->
          [{150, 50 + rel_r}, :up]
      end

    case Map.get(board[:tiles], next_pos, %{is_void: true}) do
      %{is_wall: true} ->
        {next_pos, facing}

      %{is_tile: true} ->
        {next_pos, next_facing}
    end
  end
end

IO.puts("Solve 1: #{Day22.solve_1()}")
IO.puts("Solve 2: #{Day22.solve_2()}")
