defmodule Day11 do
  defp read_input() do
    File.read!("lib/inputs/day_11.input")
    |> to_string()
    |> String.split("\n\n", trim: true)
  end

  def solve_1() do
    monkeys =
      read_input()
      |> process_monkeys()

    turns = Map.keys(monkeys) |> Enum.sort() |> List.duplicate(20) |> List.flatten()

    turns
    |> Enum.reduce(monkeys, &process_turn_with_relief/2)
    |> Enum.map(fn {_k, v} -> v.inspections end)
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.take(2)
    |> Enum.product()
  end

  def solve_2() do
    monkeys =
      read_input()
      |> process_monkeys()

    turns = Map.keys(monkeys) |> Enum.sort() |> List.duplicate(10000) |> List.flatten()

    turns
    |> Enum.reduce(monkeys, &process_turn_without_relief/2)
    |> Enum.map(fn {_k, v} -> v.inspections end)
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.take(2)
    |> Enum.product()
  end

  defp process_monkeys(input) do
    input
    |> Enum.map(&process_monkey/1)
    |> Enum.with_index()
    |> Enum.map(fn {k, v} -> {v, k} end)
    |> Map.new()
  end

  defp process_monkey(monkey_str) do
    %{
      inspections: 0,
      items: process_items(monkey_str),
      operation: process_operation(monkey_str),
      divisible_by: process_test(monkey_str),
      if_true: process_if_true(monkey_str),
      if_false: process_if_false(monkey_str)
    }
  end

  defp process_items(monkey_str) do
    [_, items] = Regex.run(~r/Starting items: (.+)/, monkey_str)
    items |> String.split(", ") |> Enum.map(&String.to_integer/1)
  end

  defp process_operation(monkey_str) do
    [_, operation] = Regex.run(~r/Operation: new = (.+)/, monkey_str)
    operation
  end

  defp process_test(monkey_str) do
    [_, divisible_by] = Regex.run(~r/Test: divisible by (.+)/, monkey_str)
    String.to_integer(divisible_by)
  end

  defp process_if_true(monkey_str) do
    [_, if_true] = Regex.run(~r/If true: throw to monkey (.+)/, monkey_str)
    String.to_integer(if_true)
  end

  defp process_if_false(monkey_str) do
    [_, if_false] = Regex.run(~r/If false: throw to monkey (.+)/, monkey_str)
    String.to_integer(if_false)
  end

  defp process_turn_with_relief(index, monkeys) do
    process_turn(index, monkeys, true)
  end

  defp process_turn_without_relief(index, monkeys) do
    process_turn(index, monkeys, false)
  end

  defp process_turn(index, monkeys, can_get_relief) do
    monkey = monkeys[index]

    monkey.items
    |> Enum.map(&calculate_transition(&1, monkey, can_get_relief))
    |> Enum.reduce(monkeys, &make_transition/2)
    |> Map.put(index, %{
      monkey
      | items: [],
        inspections: monkey.inspections + length(monkey.items)
    })
  end

  defp calculate_transition(item, monkey, can_get_relief) do
    new_item = inspect_item(item, monkey.operation, can_get_relief)

    %{
      item: new_item,
      recipient: calculate_recipient(new_item, monkey)
    }
  end

  defp inspect_item(item, operation, can_get_relief) do
    [x_str, operator, y_str] =
      operation |> String.replace("old", to_string(item)) |> String.split(" ")

    x = String.to_integer(x_str)
    y = String.to_integer(y_str)

    new_item =
      case operator do
        "*" ->
          x * y

        "+" ->
          x + y
      end

    if can_get_relief do
      floor(new_item / 3)
    else
      new_item
    end
  end

  defp calculate_recipient(worry_level, monkey) do
    case rem(worry_level, monkey.divisible_by) do
      0 ->
        monkey.if_true

      _ ->
        monkey.if_false
    end
  end

  defp make_transition(transition, monkeys) do
    recipient_monkey = monkeys[transition.recipient]

    Map.put(monkeys, transition.recipient, %{
      recipient_monkey
      | items: recipient_monkey.items ++ [rem(transition.item, common_multiple(monkeys))]
    })
  end

  def common_multiple(monkeys) do
    monkeys
    |> Enum.map(fn {_key, monkey} -> monkey.divisible_by end)
    |> List.to_tuple()
    |> Tuple.product()
  end
end

IO.puts("Solve 1: #{Day11.solve_1()}")
IO.puts("Solve 2: #{Day11.solve_2()}")
