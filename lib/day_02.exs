defmodule Day2 do
  @win 6
  @draw 3
  @lose 0

  defp read_input() do
    File.stream!("lib/inputs/day_02.input", [:read])
    |> Stream.map(&String.trim_trailing/1)
    |> Enum.to_list()
    |> Enum.map(fn str -> String.split(str) end)
  end

  def solve_1() do
    read_input()
    |> Enum.map(fn lst -> Enum.map(lst, fn move -> convert_move_to_atom(move) end) end)
    |> Enum.map(&List.to_tuple/1)
    |> Enum.map(fn {m1, m2} -> get_outcome_score(m1, m2) + get_move_score(m2) end)
    |> Enum.sum()
  end

  def solve_2() do
    read_input()
    |> Enum.map(&List.to_tuple/1)
    |> Enum.map(fn {m1, m2} -> {convert_move_to_atom(m1), convert_move_to_condition(m2)} end)
    |> Enum.map(fn {m1, con} -> {m1, get_sign_for_given_condition(m1, con)} end)
    |> Enum.map(fn {m1, m2} -> get_outcome_score(m1, m2) + get_move_score(m2) end)
    |> Enum.sum()
  end

  defp convert_move_to_atom(move) do
    cond do
      move == "A" or move == "X" ->
        :stone

      move == "B" or move == "Y" ->
        :paper

      move == "C" or move == "Z" ->
        :scissor
    end
  end

  defp convert_move_to_condition(move) do
    cond do
      move == "X" ->
        :lose

      move == "Y" ->
        :draw

      move == "Z" ->
        :win
    end
  end

  defp get_move_score(move) do
    case move do
      :stone -> 1
      :paper -> 2
      :scissor -> 3
    end
  end

  defp get_outcome_score(opponent_move, my_move) do
    case {opponent_move, my_move} do
      {m1, m2} when m1 == m2 ->
        @draw

      {m1, m2}
      when (m1 == :stone and m2 == :paper) or (m1 == :paper and m2 == :scissor) or
             (m1 == :scissor and m2 == :stone) ->
        @win

      _ ->
        @lose
    end
  end

  defp get_sign_for_given_condition(move, condition) do
    case {move, condition} do
      {:stone, :win} -> :paper
      {:stone, :draw} -> :stone
      {:stone, :lose} -> :scissor
      {:paper, :win} -> :scissor
      {:paper, :draw} -> :paper
      {:paper, :lose} -> :stone
      {:scissor, :win} -> :stone
      {:scissor, :draw} -> :scissor
      {:scissor, :lose} -> :paper
    end
  end
end

IO.puts("Solve 1: #{Day2.solve_1()}")
IO.puts("Solve 2: #{Day2.solve_2()}")
