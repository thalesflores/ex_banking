defmodule ExBanking.Accounts.User do
  alias ExBanking.Accounts.Balance
  @enforce_keys [:name]
  defstruct name: nil, balances: []

  @type t :: %__MODULE__{name: String.t(), balances: [Balance.t()]}

  @doc """
   Validates if the user exists and that process limit requests is reached.
    The queue size limit is 10
  """
  @spec available?(user :: String.t()) :: {:error, :too_many_requests_to_user | :user_does_not_exist} | {:ok, true}
  def available?(user) do
    case exist?(user) do
      :undefined -> {:error, :user_does_not_exist}
      pid -> reached_limit?(pid)
    end
  end

  defp exist?(user), do: :global.whereis_name(user)

  defp reached_limit?(pid) do
    {:message_queue_len, requests} = :erlang.process_info(pid, :message_queue_len)

    case requests > 10 do
      false -> {:ok, true}
      _ -> {:error, :too_many_requests_to_user}
    end
  end
end
