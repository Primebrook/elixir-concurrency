defmodule ServerProcess.CalculatorServer do
  @moduledoc """
  A simple calculator server that can perform basic arithmetic operations.
  It maintains the current sum on the server.
  """

  alias ServerProcess

  def start, do: ServerProcess.start(__MODULE__)

  def init, do: 0

  def get_value(server_pid), do: ServerProcess.call(server_pid, :get_value)
  def add(server_pid, value), do: ServerProcess.cast(server_pid, {:add, value})
  def sub(server_pid, value), do: ServerProcess.cast(server_pid, {:sub, value})
  def mul(server_pid, value), do: ServerProcess.cast(server_pid, {:mul, value})
  def div(server_pid, value), do: ServerProcess.cast(server_pid, {:div, value})

  def handle_call(:get_value, current_value), do: {current_value, current_value}

  def handle_cast({:add, number}, current_value), do: current_value + number
  def handle_cast({:sub, number}, current_value), do: current_value - number
  def handle_cast({:mul, number}, current_value), do: current_value * number
  def handle_cast({:div, number}, current_value), do: current_value / number
end
