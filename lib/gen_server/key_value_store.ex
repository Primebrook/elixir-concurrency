defmodule GenServer.KeyValueStore do
  @moduledoc """
  The KeyValueStore callback module.
  """
  use GenServer

  def start, do: GenServer.start(__MODULE__, nil, name: __MODULE__)

  @impl GenServer
  def init(_initial_state), do: {:ok, %{}}

  def put(key, value), do: GenServer.cast(__MODULE__, {:put, key, value})

  def get(key), do: GenServer.call(__MODULE__, {:get, key})

  @impl GenServer
  def handle_call({:get, key}, _caller, state) do
    {:reply, Map.get(state, key), state}
  end

  @impl GenServer
  def handle_cast({:put, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end
end
