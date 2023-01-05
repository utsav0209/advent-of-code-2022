defmodule Day5 do
  defp read_input() do
    File.stream!("lib/inputs/day_05.input", [:read])
    |> Stream.map(fn str -> String.trim_trailing(str, "\n") end)
    |> Enum.to_list()
  end

  def solve_1() do
    get_stacks_and_moves()
    |> make_moves(true)
  end

  def solve_2() do
    get_stacks_and_moves()
    |> make_moves(false)
  end

  defp parse_row(row) do
    row
    |> Enum.map(fn str ->
      cond do
        String.trim(str) == "" ->
          ""

        str ->
          String.at(str, 1)
      end
    end)
  end

  defp generate_stacks(stacks) do
    stack_rows =
      stacks
      |> Enum.drop(-1)
      |> Enum.map(fn str ->
        str
        |> String.codepoints()
        |> Enum.chunk_every(4)
        |> Enum.map(&Enum.join/1)
      end)
      |> Enum.map(&parse_row/1)

    acc = List.duplicate([], length(hd(stack_rows)))

    stack_rows
    |> Enum.reduce(acc, fn row, acc ->
      Enum.zip(acc, row)
      |> Enum.map(fn
        {a, ""} -> a
        {a, c} -> a ++ [c]
      end)
    end)
  end

  defp generate_moves(moves) do
    moves
    |> Enum.map(fn str -> String.replace(str, ~r/[^\d]/, " ") |> String.split() end)
    |> Enum.map(fn lst -> Enum.map(lst, fn str -> String.to_integer(str) end) end)
  end

  defp get_stacks_and_moves() do
    {stacks, moves} =
      read_input()
      |> Enum.chunk_by(fn str -> str == "" end)
      |> Enum.filter(fn str -> str != [""] end)
      |> List.to_tuple()

    stacks = generate_stacks(stacks)
    moves = generate_moves(moves)
    {stacks, moves}
  end

  defp move_items_in_stacks(stacks, from, to, to_move) do
    Enum.with_index(stacks)
    |> Enum.map(fn {col, index} ->
      cond do
        index == from ->
          col -- to_move

        index == to ->
          to_move ++ col

        true ->
          col
      end
    end)
  end

  defp make_moves({stacks, moves}, reversed) do
    moves
    |> Enum.reduce(stacks, fn [count, from, to], acc_stack ->
      from = from - 1
      to = to - 1

      to_move =
        Enum.at(acc_stack, from)
        |> Enum.take(count)
        |> then(fn crates ->
          cond do
            reversed == true ->
              Enum.reverse(crates)

            true ->
              crates
          end
        end)

      move_items_in_stacks(acc_stack, from, to, to_move)
    end)
    |> Enum.map(&hd/1)
  end
end

IO.puts("Solve 1: #{Day5.solve_1()}")
IO.puts("Solve 2: #{Day5.solve_2()}")
