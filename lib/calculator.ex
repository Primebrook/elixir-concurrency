defmodule Calculator do
  @moduledoc """
  A simple calculator server that maintains a state - the current value/sum.
  """

  ### Client functions ###
  def start do
    spawn(fn -> loop(0) end)
  end

  # (synchronous message passing - i.e. send message then immediately wait for the response)
  def value(server_pid) do
    send(server_pid, {:value, self()})

    receive do
      {:response, value} -> {:ok, value}
    end
  end

  # (asynchronous arithmetic operations - i.e send message and DOESN'T wait for response)
  def add(server_pid, value), do: send(server_pid, {:add, value})
  def sub(server_pid, value), do: send(server_pid, {:sub, value})
  def mul(server_pid, value), do: send(server_pid, {:mul, value})
  def div(server_pid, value), do: send(server_pid, {:div, value})

  ### Server functions ###
  defp loop(current_value) do
    new_value =
      receive do
        msg -> process_message(current_value, msg)
      end

    loop(new_value)
  end

  defp process_message(current_value, {:value, caller_pid}) do
    send(caller_pid, {:response, current_value})
    current_value
  end

  defp process_message(current_value, {:add, number}), do: current_value + number
  defp process_message(current_value, {:sub, number}), do: current_value - number
  defp process_message(current_value, {:mul, number}), do: current_value * number
  defp process_message(current_value, {:div, number}), do: current_value / number

  defp process_message(current_value, invalid_request) do
    IO.puts("Invalid Request: #{inspect(invalid_request)}")
    current_value
  end
end
