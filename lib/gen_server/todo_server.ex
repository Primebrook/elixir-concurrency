defmodule GenServer.TodoServer do
  @moduledoc """
  The TodoServer - the non-generic code responsible for maintaining,
  the todo list which exists on the server process.
  """

  use GenServer
  alias TodoList

  def start, do: GenServer.start(__MODULE__, nil, name: __MODULE__)

  @impl GenServer
  def init(_initial_state), do: {:ok, TodoList.new()}

  def put(entry), do: GenServer.cast(__MODULE__, {:add_entry, entry})
  def get(date), do: GenServer.call(__MODULE__, {:get_entries, date})

  @impl GenServer
  def handle_cast({:add_entry, entry}, todo_list) do
    {:noreply, TodoList.add_entry(todo_list, entry)}
  end

  @impl GenServer
  def handle_call({:get_entries, date}, _caller, todo_list) do
    {:reply, TodoList.entries(todo_list, date), todo_list}
  end
end
