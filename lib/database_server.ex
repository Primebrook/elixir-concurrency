defmodule DatabaseServer do
  @moduledoc """
  A mock database server that simulates a pool of connections.
  The database server is stateful in that it maintains connections.
  """

  ### Client functions ###
  def start_pool(pool_size) do
    1..pool_size
    |> Enum.map(fn i -> {i, start()} end)
    |> Map.new()
    |> Map.put(:pool_size, pool_size)
  end

  def start do
    spawn(fn ->
      conn = :rand.uniform(1000)
      loop(conn)
    end)
  end

  def query(%{pool_size: pool_size} = pool, query) do
    pool
    |> Map.get(:rand.uniform(pool_size))
    |> run_async(query)

    get_result()
  end

  def run_async(server_pid, query) do
    send(server_pid, {:query, self(), query})
  end

  def get_result do
    receive do
      {:response, result} -> {:response, result}
    after
      5000 -> {:error, "timeout"}
    end
  end

  ### Server functions ###
  defp loop(conn) do
    receive do
      {:query, caller_pid, query} ->
        query_result = run_query(conn, query)
        send(caller_pid, {:response, query_result})
    end

    loop(conn)
  end

  defp run_query(conn, query) do
    # Simulate a long running query
    Process.sleep(2000)
    "Connection #{conn}: #{query}"
  end
end
