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

  def read_state(server_pid) do
    send(server_pid, {:state, self()})

    receive do
      {:response, msg} -> msg
    after
      5000 -> {:error, "timeout"}
    end
  end

  def update_state(server_pid, message), do: send(server_pid, {:message, self(), message})

  ### Server functions ###
  defp loop(callback_module, current_state) do
    new_state =
      receive do
        {:message, caller_pid, message} ->
          {response, new_state} = callback_module.handle_message(current_state, message)
          send(caller_pid, {:response, response})
          new_state

        {:state, caller_pid} ->
          send(caller_pid, {:response, current_state})
          current_state
      end

    loop(callback_module, new_state)
  end
end

defmodule MockCallbackModule do
  @moduledoc """
  A mock callback module which must implement:

  1. init/1: which provides the initial state of the server. 
  2. handle_call/2: which handles the messages received by the server.
  """

  def start_link, do: ServerProcess.start(__MODULE__)

  def init, do: "initial state"

  def handle_message(current_state, message), do: {"message handled", current_state <> message}
end
