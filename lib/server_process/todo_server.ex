defmodule ServerProcess.TodoServer do
  @moduledoc """
  The TodoServer - the non-generic code responsible for maintaining,
  the todo list which exists on the server process.
  """

  alias ServerProcess
  alias TodoList

  def start, do: ServerProcess.start(__MODULE__)

  def init, do: TodoList.new()

  def put(server_pid, entry), do: ServerProcess.cast(server_pid, {:add_entry, entry})
  def get(server_pid, date), do: ServerProcess.call(server_pid, {:get_entries, date})

  def handle_cast({:add_entry, entry}, todo_list), do: TodoList.add_entry(todo_list, entry)

  def handle_call({:get_entries, date}, todo_list),
    do: {TodoList.entries(todo_list, date), todo_list}
end
