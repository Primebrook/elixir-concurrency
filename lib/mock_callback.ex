defmodule MockCallbackModule do
  @moduledoc """
  A mock callback module which must implement:

  1. init/1: which provides the initial state of the server. 
  2. handle_call/2: which handles the messages received by the server.


  The callback module should also contain the interface functions that
  the client uses to interact with the server.
  """
  def init, do: "initial state"

  def handle_call(message, current_state), do: {"Message Consumed!", current_state <> message}
end
