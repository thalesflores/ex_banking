defmodule ExBanking.Server do
  use GenServer
  alias ExBanking.Accounts.User
  alias ExBanking.Accounts.Balance

  @impl true
  def init(user), do: {:ok, %User{name: user}}

  @impl true
  def handle_call({:deposit, amount, currency}, _from, user) do
    deposit = Balance.deposit(user.balances, amount, currency)
    updated_user = Map.put(user, :balances, deposit)
    current_amount = Balance.get_amount(deposit, currency)
    {:reply, {:ok, current_amount}, updated_user}
  end
end
