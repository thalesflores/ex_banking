defmodule ExBanking.Accounts.User do
  alias ExBanking.Accounts.Balance
  @enforce_keys [:name]
  defstruct name: nil, balances: []

  @type t :: %__MODULE__{name: String.t(), balances: [Balance.t()]}
end
