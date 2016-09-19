defmodule Poker do
  import Supervisor.Spec, warn: false
  
  def start(_type, _args) do
    children = [worker(Poker.PokerServer, [])]
    opts = [strategy: :one_for_one, name: Poker.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
