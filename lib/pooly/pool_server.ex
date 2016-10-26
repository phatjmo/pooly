defmodule Pooly.PoolServer do
  use GenServer
  import Supervisor.Spec

  defmodule State do
    defstruct pool_sup: nil, worker_sup: nil, monitors: nil, size: nil, workers: nil, name: nil, mfa: nil
  end

  #######
  # API #
  #######

  def start_link(pool_sup, pool_config) do
    GenServer.start_link(__MODULE__, [pool_sup, pool_config], name: name(pool_config[:name]))
  end

  def checkout(pool_name) do
    GenServer.call(name(pool_name), :checkout)
  end

  def checkin(pool_name, worker_pid) do
    GenServer.cal(name(pool_name), {:checkin, worker_pid})
  end

  def status(pool_name) do
    GenServer.call(name(pool_name), :status)
  end

  #############
  # Callbacks #
  #############

  def init([pool_sup, pool_config]) when is_pid(pool_sup) do
    Process.flag(:trap_exit, true)
    monitors = :ets.new(:monitors, [:private])
    init(pool_config, %State{pool_sup: pool_sup, monitors: monitors})
  end

  def init([{:name, anme}|rest], state) do
    # ...
  end

  def init([{:mfs, mfa}|rest], state) do
    # ...
  end

  def init([{:size, size}|rest], state) do
    # ...
  end

  def init([], state) do
    send(self, :start_worker_supervisor)
    {:ok, state}
  end

  def init([_|rest], state) do
    # ...
  end

  def handle_call(:checkout, {from_pid, _ref}, %{workers: workers, monitors: monitors} = state) do
    # ...
  end

  def handle_call(:status, _from, %{workers: workers, monitors: monitors} = state) do
    # ...
  end

  def handle_cast({:checkin, worker}, %{workers: workers, monitors: monitors} = state) do
    # ...
  end

  def handle_info(:start_worker_supervisor, state = %{pool_sup: pool_sup, name: name, mfa: mfa, size: size}) do
    {:ok, worker_sup} = Supervisor.start_child(pool_sup, supervisor_spec(name, mfa))
    workers = prepopulate(size, worker_sup)
    {:noreply, %{state | worker_sup: worker_sup, workers: workers}}
  end

  def  handle_info({:DOWN, ref, _, _, _}, state = %{monitors: monitors, workers: workers}) do
    # ...
  end

  def handle_info({:EXIT, pid, _reason}, state = %{monitors: monitors, workers: workers, pool_sup: pool_sup}) do
    case :ets.lookup(monitors, pid) do
      [{pid, ref}] ->
        true = Process.demonitor(ref)
        true = :ets.delete(monitors, pid)
        new_state = %{state | workers: [new_worker(pool_sup)|workers]}
        {:noreply, new_state}

      _ ->
        {:noreply, state}
    end
  end

  def terminate(_reason, _state) do
    :ok
  end

  #####################
  # Private Functions #
  #####################

  def name(pool_name) do
    :"#{pool_name}Server"
  end

  defp prepopulate(size, sup) do
    # ... <- you need to get these from the old server.ex!!!
  end

  defp prepopulate(size, _sup, workers) when size < 1 do
    # ...
end
  defp prepopulate(size, sup, workers) do
    # ...
end
  defp new_worker(sup) do
    # ...
end

defp supervisor_spec(name, mfa) do
    opts = [id: name <> "WorkerSupervisor", restart: :temporary]
    supervisor(Pooly.WorkerSupervisor, [self, mfa], opts)
end

end