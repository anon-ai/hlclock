defmodule HLClock.Supervisor do
  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def init(opts) do
    children = [
      worker(HLClock.Server, [opts])
    ]

    Supervisor.init(children, [strategy: :one_for_one])
  end
end
