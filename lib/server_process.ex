defmodule ServerProcess do
  @moduledoc """
  An implementation for a generic server process - designed for plugin to other
  module (callback module) 
  """

  ### Client functions ###
  def start(callback_module) do
    spawn(fn ->
      initial_state = callback_module.init()
      loop(callback_module, initial_state)
    end)
  end

  def call(server_pid, message) do
    send(server_pid, {:call, message, self()})

    receive do
      {:response, response} -> response
    after
      5000 -> {:error, "timeout"}
    end
  end

  def cast(server_pid, message), do: send(server_pid, {:cast, message, self()})

  ### Server functions ###
  defp loop(callback_module, current_state) do
    receive do
      {:call, message, caller_pid} ->
        {response, new_state} = callback_module.handle_call(message, current_state)
        send(caller_pid, {:response, response})

        loop(callback_module, new_state)

      {:cast, message, _caller_pid} ->
        new_state = callback_module.handle_cast(message, current_state)

        loop(callback_module, new_state)
    end
  end
end
