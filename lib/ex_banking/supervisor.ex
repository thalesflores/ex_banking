defmodule ExBanking.Supervisor do
  use Supervisor

  @name __MODULE__

  def start_link do
    Supervisor.start_link(@name, [], name: @name)
  end

  def init(_) do
    children = [
      worker(ExBanking.Server, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  def create_user(user) do
    case Supervisor.start_child(@name, [user]) do
      {:ok, _} -> :ok
      {:error, {:already_started, _}} -> {:error, :user_already_exists}
    end
  end
end
