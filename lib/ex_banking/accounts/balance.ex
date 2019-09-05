defmodule ExBanking.Accounts.Balance do
  @enforce_keys [:currency]
  defstruct currency: nil, amount: 0.00
  @type t :: %__MODULE__{currency: String.t(), amount: float}

  alias ExBanking.Operations

  @spec deposit(balances :: [], amount :: number(), currency :: String.t()) :: [__MODULE__.t()]
  def deposit(balances, amount, currency) do
    balances
    |> get(currency)
    |> update_balance(amount, currency, &Operations.sum/2)
    |> return_balance(balances, currency)
  end

  @spec get_amount(list(), String.t()) :: float() | nil
  def get_amount(balances, currency) do
    case get(balances, currency) do
      nil -> 0.00
      balance -> Map.get(balance, :amount)
    end
  end

  @spec withdraw(balances :: [], amount :: number(), currency :: String.t()) :: list() | {:error, :not_enough_money}
  def withdraw(balances, amount, currency) do
    balances
    |> get(currency)
    |> has_enough_money?(amount)
    |> update_balance(amount, currency, &Operations.sub/2)
    |> return_balance(balances, currency)
  end

  @spec get(balances :: list(), currency :: String.t()) :: __MODULE__.t() | nil
  defp get(balances, currency) do
    balances
    |> Enum.filter(&(Map.get(&1, :currency) == currency))
    |> Enum.at(0)
  end

  @spec update_balance(currency_balance :: nil, amount :: number(), currency :: String.t(), _ :: any()) ::
          __MODULE__.t()
  defp update_balance(_currency_balance = nil, amount, currency, _operation) do
    %__MODULE__{
      currency: currency,
      amount: Operations.round_amount(amount)
    }
  end

  @spec update_balance(
          {true | false, balance :: __MODULE__.t()},
          amount :: number(),
          currency :: String.t(),
          operation :: function()
        ) ::
          __MODULE__.t() | tuple()
  defp update_balance({true, balance}, amount, currency, operation) do
    update_balance(balance, amount, currency, operation)
  end

  defp update_balance({false, _balance}, _amount, _currency, _operation), do: {:error, :not_enough_money}

  @spec update_balance(balance :: __MODULE__.t(), amount :: number(), currency :: String.t(), operation :: function()) ::
          __MODULE__.t()
  defp update_balance(balance, amount, _currency, operation) do
    rounded_amount = Operations.round_amount(operation.(balance.amount, amount))

    Map.put(balance, :amount, rounded_amount)
  end

  defp return_balance(error = {:error, _msg}, _balances, _currency), do: error

  defp return_balance(currency_balance, balances, currency) do
    balances
    |> Enum.reject(&(Map.get(&1, :currency) == currency))
    |> Enum.concat([currency_balance])
  end

  defp has_enough_money?(balance = nil, _amount), do: {false, balance}

  defp has_enough_money?(balance, amount) do
    case balance.amount >= amount do
      true -> {true, balance}
      _ -> {false, balance}
    end
  end
end
