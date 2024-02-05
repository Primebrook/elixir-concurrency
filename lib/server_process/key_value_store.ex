defmodule ServerProcess.KeyValueStore do
  @moduledoc """
  The KeyValueStore callback module. This will be running in the server process.

  Recall the callback process must implement: init/0 and handle_call/2 - these  are both callback functions
  used internally by the generic server process code. 

  In contrast, we implement the interface functions: start/0, get/2 and put/3 so that the client never has
  to know about the ServerProcess module.
  """
  alias ServerProcess

  def start, do: ServerProcess.start(__MODULE__)

  def init, do: %{}

  def put(server_pid, key, value), do: ServerProcess.cast(server_pid, {:put, key, value})

  def get(server_pid, key), do: ServerProcess.call(server_pid, {:get, key})

  def handle_call({:get, key}, state), do: {Map.get(state, key), state}

  def handle_cast({:put, key, value}, state), do: Map.put(state, key, value)
end
