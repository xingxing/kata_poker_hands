defmodule Poker.PokerServer do
  import Poker.PokerHands, only: [main: 1]
  use GenServer

  @name __MODULE__

  # API
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  def game(game) do
    GenServer.call(@name, {:game, game})
  end

  # Callbacks
  def init(:ok) do
    {:ok, nil}
  end

  def handle_call({:game, game}, _form, nil) do
    {:reply, main(game), nil}
  end
end
