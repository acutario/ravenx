defmodule Ravenx.DispatchWorker do
  use GenServer

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], [])
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:dispatch, handler, payload, opts}, _from , state) do
    result = handler.call(payload, opts)
    {:reply, result, state}
  end
end
