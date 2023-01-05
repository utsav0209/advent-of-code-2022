defmodule Day21 do
  @low -1_000_000_000_000_000_000_000
  @high 1_000_000_000_000_000_000_000

  defp read_input() do
    File.read!("lib/inputs/day_21.input")
    |> to_string()
  end

  def solve_1() do
    monkeys =
      read_input()
      |> parse_monkeys()

    monkey_yells(monkeys["root"], monkeys)
  end

  def solve_2() do
    monkeys =
      read_input()
      |> parse_monkeys()

    monkeys = Map.put(monkeys, "root", %{monkeys["root"] | operation: "-"})

    binary_search(monkeys, @low, @high)
  end

  defp binary_search(monkeys, low, high) do
    guess = div(low + high, 2)
    monkey_with_human_guess = Map.put(monkeys, "humn", %{yells: guess})

    root = monkey_yells(monkeys["root"], monkey_with_human_guess)

    if root == 0 do
      guess
    else
      if root > 0 do
        binary_search(monkeys, guess + 1, high)
      else
        binary_search(monkeys, low, guess)
      end
    end
  end

  defp parse_monkeys(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_monkey/1)
    |> Map.new()
  end

  defp parse_monkey(monkey_str) do
    [monkey_name, monkey_number] = String.split(monkey_str, ": ", trim: true)

    case String.split(monkey_number) do
      [monkey_1, operation, monkey_2] ->
        {monkey_name, %{monkey_1: monkey_1, monkey_2: monkey_2, operation: operation}}

      [number] ->
        {monkey_name, %{yells: String.to_integer(number)}}
    end
  end

  defp monkey_yells(%{yells: yells}, _), do: yells

  defp monkey_yells(
         %{monkey_1: monkey_1, monkey_2: monkey_2, operation: operation},
         monkeys
       ) do
    do_operation(
      monkey_yells(monkeys[monkey_1], monkeys),
      monkey_yells(monkeys[monkey_2], monkeys),
      operation
    )
  end

  defp do_operation(op1, op2, operation) do
    case operation do
      "+" ->
        op1 + op2

      "-" ->
        op1 - op2

      "*" ->
        op1 * op2

      "/" ->
        (op1 / op2) |> trunc()
    end
  end
end

IO.puts("Solve 1: #{Day21.solve_1()}")
IO.puts("Solve 2: #{Day21.solve_2()}")
