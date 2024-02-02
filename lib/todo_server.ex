defmodule TodoList do
  defstruct auto_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %TodoList{},
      &add_entry(&2, &1)
    )
  end

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.auto_id)
    new_entries = Map.put(todo_list.entries, todo_list.auto_id, entry)

    %TodoList{todo_list | entries: new_entries, auto_id: todo_list.auto_id + 1}
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  def update_entry(todo_list, %{} = new_entry) do
    update_entry(todo_list, new_entry.id, fn _ -> new_entry end)
  end

  def update_entry(todo_list, entry_id, updater_fun) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error ->
        todo_list

      {:ok, old_entry} ->
        new_entry = updater_fun.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def delete_entry(todo_list, entry_id) do
    %TodoList{todo_list | entries: Map.delete(todo_list.entries, entry_id)}
  end
end

defmodule TodoServer do
  ### Client functions ###
  def start, do: spawn(fn -> loop(TodoList.new()) end)

  def add_entry(server_pid, entry), do: send(server_pid, {:new_entry, entry})

  def delete_entry(server_pid, entry_id), do: send(server_pid, {:delete_entry, entry_id})

  def entries(server_pid, date) do
    send(server_pid, {:entries, self(), date})

    receive do
      {:response, entries} -> entries
    after
      5000 -> {:error, "timeout"}
    end
  end

  ### Server functions ###
  defp loop(todo_list) do
    new_todo_list =
      receive do
        message -> process_message(todo_list, message)
      end

    loop(new_todo_list)
  end

  defp process_message(todo_list, {:new_entry, entry}), do: TodoList.add_entry(todo_list, entry)

  defp process_message(todo_list, {:delete_entry, entry_id}),
    do: TodoList.delete_entry(todo_list, entry_id)

  defp process_message(todo_list, {:entries, caller_pid, date}) do
    send(caller_pid, {:response, TodoList.entries(todo_list, date)})
    todo_list
  end
end
