defmodule ExBanking.Server do
  use GenServer
  alias ExBanking.Accounts.User
  alias ExBanking.Accounts.Balance

  def start_link(user), do: GenServer.start_link(__MODULE__, nil, name: {:global, user})

  @impl true
  def init(user) do
    {:ok, %User{name: user}}
  end

  @impl true
  def handle_call({:deposit, amount, currency}, _from, user) do
    balance = Balance.deposit(user.balances, amount, currency)
    {current_amount, updated_user} = handle_response(user, balance, currency)

    {:reply, {:ok, current_amount}, updated_user}
  end

  @impl true
  def handle_call({:withdraw, amount, currency}, _from, user) do
    balance = Balance.withdraw(user.balances, amount, currency)

    case is_list(balance) do
      true ->
        {current_amount, updated_user} = handle_response(user, balance, currency)
        {:reply, {:ok, current_amount}, updated_user}

      _ ->
        {:reply, {:error, :not_enough_money}, user}
    end
  end

  @impl true
  def handle_call({:get_balance, currency}, _from, user) do
    balance = Balance.get_amount(user.balances, currency)
    {:reply, {:ok, balance}, user}
  end

  @spec handle_response(user :: User.t(), balance :: list(), currency :: String.t()) :: tuple()
  defp handle_response(user, balance, currency) do
    current_amount = Balance.get_amount(balance, currency)
    updated_user = Map.put(user, :balances, balance)
    {current_amount, updated_user}
  end
end
