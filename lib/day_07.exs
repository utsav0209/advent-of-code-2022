defmodule Day7 do
  @total_size 70_000_000
  @required_size 30_000_000
  @max_dir_size 100_000

  defp read_input() do
    File.stream!("lib/inputs/day_07.input", [:read])
    |> Stream.map(fn str -> String.trim_trailing(str, "\n") end)
    |> Enum.to_list()
  end

  def solve_1() do
    read_input()
    |> parse()
    |> Map.values()
    |> Enum.filter(fn v -> v <= @max_dir_size end)
    |> Enum.sum()
  end

  def solve_2() do
    read_input()
    |> parse()
    |> Map.to_list()
    |> Enum.sort(fn {_k1, v1}, {_k2, v2} -> v1 <= v2 end)
    |> find_minimum_to_delete()
  end

  defp parse(command), do: parse(command, %{}, [])

  defp parse([], tree, _current_path), do: tree

  defp parse(["$ cd .." | rest], tree, [_ | current_path]), do: parse(rest, tree, current_path)

  defp parse(["$ cd " <> dir | rest], tree, current_path),
    do: parse(rest, tree, [dir | current_path])

  defp parse(["dir" <> _dir | rest], tree, current_path), do: parse(rest, tree, current_path)

  defp parse(["$ ls" | rest], tree, current_path), do: parse(rest, tree, current_path)

  defp parse([dir | rest], tree, current_path),
    do: parse(rest, update_size(current_path, tree, dir), current_path)

  defp get_size(dir) do
    dir
    |> String.split(" ")
    |> hd()
    |> String.to_integer()
  end

  defp update_size(current_path, tree, dir) do
    current_path
    |> Enum.reverse()
    |> Enum.reduce({"/", tree}, fn
      "/", {path, acc_tree} ->
        {path, Map.put(acc_tree, "/", Map.get(acc_tree, "/", 0) + get_size(dir))}

      cur_dir, {path, acc_tree} ->
        {path <> "/" <> cur_dir,
         Map.put(
           acc_tree,
           path <> "/" <> cur_dir,
           Map.get(acc_tree, path <> "/" <> cur_dir, 0) + get_size(dir)
         )}
    end)
    |> elem(1)
  end

  defp find_minimum_to_delete(tree) do
    find_minimum_to_delete(tl(tree), List.last(tree))
  end

  defp find_minimum_to_delete([{_curr, curr_size} | _], {_parent, parent_size})
       when @total_size - parent_size + curr_size >= @required_size,
       do: curr_size

  defp find_minimum_to_delete([_ | rest], root), do: find_minimum_to_delete(rest, root)
end

IO.puts("Solve 1: #{Day7.solve_1()}")
IO.puts("Solve 2: #{Day7.solve_2()}")
