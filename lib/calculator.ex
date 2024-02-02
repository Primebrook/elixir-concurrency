defmodule Calculator do
  @moduledoc """
  A simple calculator server that maintains a state - the current value/sum.
  """

  # Client functions
  def start do
    spawn(fn -> loop(0) end)
  end

  def get_value do
    receive do
      {:response, value} -> {:response, value}
    after
      5000 -> {:error, "timeout"}
    end
  end

  def value(server_pid), do: send(server_pid, {:value, self()})
  def add(server_pid, value), do: send(server_pid, {:add, value})
  def sub(server_pid, value), do: send(server_pid, {:sub, value})
  def mul(server_pid, value), do: send(server_pid, {:mul, value})
  def div(server_pid, value), do: send(server_pid, {:div, value})

  # Server functions
  defp loop(current_value) do
    new_value =
      receive do
        {:value, caller_pid} ->
          send(caller_pid, {:response, current_value})
          current_value

        {:add, number} -> current_value + number
        {:sub, number} -> current_value - number
        {:mul, number} -> current_value * number
        {:div, number} -> current_value / number

        invalid_request -> IO.puts("Invalid Request: #{inspect invalid_request}") ; current_value
      end

    loop(new_value)
  end
end
