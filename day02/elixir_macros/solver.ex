defmodule Day2Solution do
  defmacro start do
    quote do
      var!(submarine1) = var!(submarine2) = %{horizontal: 0, depth: 0, aim: 0}
    end
  end
  
  defmacro forward(n) do
    quote do
      var!(submarine1) = %{var!(submarine1) | horizontal: var!(submarine1).horizontal + unquote(n)}
      var!(submarine2) = %{var!(submarine2) | horizontal: var!(submarine2).horizontal + unquote(n)}
      var!(submarine2) = %{var!(submarine2) | depth: var!(submarine2).depth + unquote(n) * var!(submarine2).aim}
    end
  end

  defmacro down(n) do
    quote do
      var!(submarine1) = %{var!(submarine1) | depth: var!(submarine1).depth + unquote(n)}
      var!(submarine2) = %{var!(submarine2) | aim: var!(submarine2).aim + unquote(n)}
    end
  end

  defmacro up(n) do
    quote do
      var!(submarine1) = %{var!(submarine1) | depth: var!(submarine1).depth - unquote(n)}
      var!(submarine2) = %{var!(submarine2) | aim: var!(submarine2).aim - unquote(n)}
    end
  end

  defmacro stop do
    quote do
      IO.puts("Part 1: #{var!(submarine1).horizontal * var!(submarine1).depth}")
      IO.puts("Part 2: #{var!(submarine2).horizontal * var!(submarine2).depth}")
    end
  end
end
