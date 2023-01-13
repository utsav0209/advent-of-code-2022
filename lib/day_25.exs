defmodule Day25 do
  @from_snafu_to_digit %{"=" => -2, "-" => -1, "0" => 0, "1" => 1, "2" => 2}
  @snafu_to_string %{-2 => "=", -1 => "-", 0 => "0", 1 => "1", 2 => "2"}
  @from_digit_to_snafu %{0 => {0, 0}, 1 => {0, 1}, 2 => {0, 2}, 3 => {1, -2}, 4 => {1, -1}}

  defp read_input() do
    File.read!("lib/inputs/day_25.input")
    |> to_string()
  end

  def solve_1() do
    read_input() |> parse_input() |> sum_numbers() |> convert_to_snafu()
  end

  defp parse_input(input_str) do
    input_str
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
  end

  defp sum_numbers(numbers) do
    Enum.map(numbers, &convert_to_decimal/1) |> Enum.sum()
  end

  defp convert_to_decimal(number) do
    number
    |> Enum.map(&@from_snafu_to_digit[&1])
    |> Integer.undigits(5)
  end

  defp convert_to_snafu(number) do
    number
    |> Integer.digits(5)
    |> Enum.reduce([], fn digit, prev ->
      {carry, digit} = @from_digit_to_snafu[digit]
      [digit | propagate_carry(carry, prev)]
    end)
    |> Enum.reverse()
    |> Enum.map(&@snafu_to_string[&1])
    |> Enum.join()
  end

  def propagate_carry(0, prev), do: prev
  def propagate_carry(1, [hd | tl]) when hd + 1 <= 2, do: [hd + 1 | tl]
  def propagate_carry(1, [_ | tl]), do: [-2 | propagate_carry(1, tl)]
end

IO.puts("Solve 1: #{Day25.solve_1()}")
