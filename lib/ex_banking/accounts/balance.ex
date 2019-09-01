defmodule ExBanking.Accounts.Balance do
  @enforce_keys [:currency]
  defstruct currency: nil, amount: 0.0
  @type t :: %__MODULE__{currency: String.t(), amount: float}

  @spec deposit(balances :: [], amount :: number(), currency :: String.t()) :: [__MODULE__.t()]
  def deposit(balances, amount, currency) do
    balances
    |> get(currency)
    |> update_balance(amount, currency)
    |> return_balance(balances, currency)
  end

  def get_amount(balances, currency) do
    get(balances, currency)
    |> Map.get(:amount)
  end

  @spec get(balances :: list(), currency :: String.t()) :: __MODULE__.t() | nil
  defp get(balances, currency) do
    balances
    |> Enum.filter(&(Map.get(&1, :currency) == currency))
    |> Enum.at(0)
  end

  @spec update_balance(currency_balance :: nil, amount :: number(), currency :: String.t()) :: __MODULE__.t()
  defp update_balance(_currency_balance = nil, amount, currency) do
    %__MODULE__{
      currency: currency,
      amount: round_amount(amount)
    }
  end

  @spec update_balance(balance :: __MODULE__.t(), amount :: number(), currency :: String.t()) :: __MODULE__.t()
  defp update_balance(balance, amount, _currency), do: Map.put(balance, :amount, round_amount(balance.amount + amount))

  defp return_balance(currency_balance, balances, currency) do
    balances
    |> Enum.reject(&(Map.get(&1, :currency) == currency))
    |> Enum.concat([currency_balance])
  end

  defp round_amount(amount), do: Float.round(amount, 2)
end
