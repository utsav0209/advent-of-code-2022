defmodule Stack do
  defstruct array: []

  def new do
    %Stack{}
  end

  def push(%Stack{array: array}, item) do
    %Stack{array: [item | array]}
  end

  def pop(%Stack{array: [head | rest]}) do
    {head, %Stack{array: rest}}
  end

  def pop(%Stack{array: []} = stack) do
    {nil, stack}
  end

  def peek(%Stack{array: [head | _]}) do
    head
  end
end

defmodule Day13 do
  @dividers [[[2]], [[6]]]

  defp read_input() do
    File.read!("lib/inputs/day_13.input")
    |> to_string()
    |> String.split("\n\n", trim: true)
  end

  def solve_1() do
    read_input()
    |> Enum.map(&parse_parts/1)
    |> Enum.with_index(1)
    |> Enum.filter(fn {signals, _} ->
      is_in_order?(Enum.at(signals, 0), Enum.at(signals, 1))
    end)
    |> Enum.map(fn {_, index} -> index end)
    |> Enum.sum()
  end

  def solve_2() do
    read_input()
    |> Enum.map(&parse_parts/1)
    |> Enum.reduce([], fn part, acc -> acc ++ part end)
    |> Enum.concat(@dividers)
    |> Enum.sort(&is_in_order?/2)
    |> Enum.with_index(1)
    |> Enum.filter(fn {packet, _} -> packet in @dividers end)
    |> Enum.map(fn {_, index} -> index end)
    |> List.to_tuple()
    |> Tuple.product()
  end

  defp parse_parts(parts_str) do
    String.split(parts_str, "\n", trim: true)
    |> Enum.map(&parse_signal(&1))
  end

  defp parse_signal(signal) do
    Regex.split(~r/,|\[|\]/, signal, include_captures: true, trim: true)
    |> Enum.filter(fn x -> x != "," end)
    |> parse_signal(Stack.new())
    |> Stack.peek()
  end

  defp parse_signal([], stack), do: stack
  defp parse_signal(["" | rest], stack), do: parse_signal(rest, stack)
  defp parse_signal(["," | rest], stack), do: parse_signal(rest, stack)
  defp parse_signal(["[" | rest], stack), do: parse_signal(rest, Stack.push(stack, "["))

  defp parse_signal(["]" | rest], stack) do
    {stack, list} = pop_list_group(stack, [])
    stack = Stack.push(stack, list)
    parse_signal(rest, stack)
  end

  defp parse_signal([head | rest], stack),
    do: parse_signal(rest, Stack.push(stack, String.to_integer(head)))

  defp pop_list_group(stack, list) do
    {head, stack} = Stack.pop(stack)

    if head == "[" do
      {stack, list}
    else
      pop_list_group(stack, [head] ++ list)
    end
  end

  defp is_in_order?(p1, p2) when p1 == p2, do: :same
  defp is_in_order?([], _), do: true
  defp is_in_order?(_, []), do: false

  defp is_in_order?([h1 | _], [h2 | _]) when is_integer(h1) and is_integer(h2) and h1 < h2,
    do: true

  defp is_in_order?([h1 | _], [h2 | _]) when is_integer(h1) and is_integer(h2) and h1 > h2,
    do: false

  defp is_in_order?([h1 | t1], [h2 | t2]) when is_integer(h1) and is_integer(h2),
    do: is_in_order?(t1, t2)

  defp is_in_order?([h1 | t1], [h2 | t2]) do
    case is_in_order?(h1, h2) do
      :same ->
        is_in_order?(t1, t2)

      result ->
        result
    end
  end

  defp is_in_order?(h1, h2), do: is_in_order?(List.wrap(h1), List.wrap(h2))
end

IO.puts("Solve 1: #{Day13.solve_1()}")
IO.puts("Solve 2: #{Day13.solve_2()}")
