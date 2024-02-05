defmodule ServerProcess do
  @moduledoc """
  An implementation for a generic server process - designed for plugin to another
  module (callback module). The callback module provides the specifics around:

  1. initial state
  2. handling messages recieved by the server.
  """

  ### Client functions ###
  def start(callback_module) do
    spawn(fn ->
      initial_state = callback_module.init()
      loop(callback_module, initial_state)
    end)
  end

  def call(server_pid, message) do
    send(server_pid, {message, self()})

    receive do
      {:response, response} -> response
    after
      5000 -> {:error, "timeout"}
    end
  end

  def update_state(server_pid, message), do: send(server_pid, {:message, self(), message})

  ### Server functions ###
  defp loop(callback_module, current_state) do
    receive do
      {message, caller_pid} ->
        {response, new_state} = callback_module.handle_call(message, current_state)
        send(caller_pid, {:response, response})

        loop(callback_module, new_state)
    end
  end
end

defmodule KeyValueStore do
  @moduledoc """
  The KeyValueStore callback module. This will be running in the server process.

  Recall the callback process must implement: init/0 and handle_call/2 - these  are both callback functions
  used internally by the generic server process code. 

  In contrast, we implement the interface functions: start/0, get/2 and put/3 so that the client never has
  to know about the ServerProcess module.
  """
  def start, do: ServerProcess.start(__MODULE__)

  def init, do: %{}

  def put(server_pid, key, value), do: ServerProcess.call(server_pid, {:put, key, value})

  def get(server_pid, key), do: ServerProcess.call(server_pid, {:get, key})

  def handle_call({:put, key, value}, state), do: {:ok, Map.put(state, key, value)}
  def handle_call({:get, key}, state), do: {Map.get(state, key), state}
end
