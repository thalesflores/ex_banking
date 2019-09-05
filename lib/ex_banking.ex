defmodule ExBanking do
  alias ExBanking.Server
  alias ExBanking.Accounts.User

  @wrong_arguments_error {:error, :wrong_arguments}

  defguard binaries?(value1, value2) when is_binary(value1) and is_binary(value2)
  defguard binaries?(value1, value2, value3) when is_binary(value1) and is_binary(value2) and is_binary(value3)
  defguard valid_amount?(value) when is_number(value) and value > 0
  defguard valid_transaction?(from_user, to_user) when from_user != to_user

  @type banking_error ::
          {:error,
           :wrong_arguments
           | :user_already_exists
           | :user_does_not_exist
           | :not_enough_money
           | :sender_does_not_exist
           | :receiver_does_not_exist
           | :too_many_requests_to_user
           | :too_many_requests_to_sender
           | :too_many_requests_to_receiver}

  @doc """
    creates an user with name and a zeroed balance.

    ## Params
      name: String

    ## Examples
      iex> ExBanking.create_user("name")
      :ok

      iex> ExBanking.create_user("name")
      {:error, :user_already_exists}
  """
  @spec create_user(user :: String.t()) :: :ok | banking_error
  def create_user(user) when is_binary(user), do: ExBanking.Supervisor.create_user(user)
  def create_user(_user), do: @wrong_arguments_error

  @doc """
    insert an amount of money to the given user and currency

    ## Params
      user: String
      amount: Float
      currency: String

    ## Examples

      iex> ExBanking.deposit("name", 100, "dolar")
      {:ok, 100.00}

      iex> ExBanking.deposit("names", 10.50, "dolar")
      {:error, :user_does_not_exist}
  """
  @spec deposit(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number} | banking_error
  def deposit(user, amount, currency) when binaries?(user, currency) and valid_amount?(amount) do
    execute_call(user, {:global, user}, {:deposit, amount, currency})
  end

  def deposit(_user, _amount, _currency), do: @wrong_arguments_error

  @doc """
    remove an amount of money to the given user and currency

    ## Params
      user: String
      amount: Float
      currency: String

    ## Examples

      iex> ExBanking.withdraw("name", 50.0, "dolar")
      {:ok, 50.0}

      iex> ExBanking.withdraw("name", 100, "real")
      {:error, :not_enough_money}
  """
  @spec withdraw(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number} | banking_error
  def withdraw(user, amount, currency) when binaries?(user, currency) and valid_amount?(amount) do
    execute_call(user, {:global, user}, {:withdraw, amount, currency})
  end

  def withdraw(_user, _amount, _currency), do: @wrong_arguments_error

  @doc """
    returns the current balance to the givem user and currency

    ## Params
      user: String
      currency: String

    ## Examples

      iex> ExBanking.get_balance("name", "dolar")
      {:ok, 100.0}

      iex> ExBanking.get_balance("names", "dolar")
      {:error, :user_does_not_exist}
  """
  @spec get_balance(user :: String.t(), currency :: String.t()) :: {:ok, balance :: number} | banking_error
  def get_balance(user, currency) when binaries?(user, currency) do
    execute_call(user, {:global, user}, {:get_balance, currency})
  end

  def get_balance(_user, _currency), do: @wrong_arguments_error

  @doc """
    transfers money between users.

    ## Params
      from_user: String
      to_user: String
      amount: Float
      currency: String

    ## Examples

      iex> ExBanking.send("name", "name2", 50.0, "dolar")
      {:ok, 0.0, 50.0}

      iex> ExBanking.send("names", "name2", 100.0, "dolar")
      {:error, :sender_does_not_exist}
  """
  @spec send(
          from_user :: String.t(),
          to_user :: String.t(),
          amount :: number,
          currency :: String.t()
        ) :: {:ok, from_user_balance :: number, to_user_balance :: number} | banking_error
  def send(from_user, to_user, amount, currency)
      when binaries?(from_user, to_user, currency) and valid_amount?(amount) and valid_transaction?(from_user, to_user) do
    with {:ok, true} <- user_available?(from_user, "sender"),
         {:ok, true} <- user_available?(to_user, "receiver"),
         {:ok, from_user_new_balance} <- GenServer.call({:global, from_user}, {:withdraw, amount, currency}),
         {:ok, to_user_new_balance} <- GenServer.call({:global, to_user}, {:deposit, amount, currency}) do
      {:ok, from_user_new_balance, to_user_new_balance}
    else
      error -> error
    end
  end

  def send(_from_user, _to_user, _amount, _currency), do: @wrong_arguments_error

  defp execute_call(user, user_pid, params) do
    with {:ok, true} <- User.available?(user) do
      GenServer.call(user_pid, params)
    end
  end

  defp user_available?(user, prefix) do
    case User.available?(user) do
      {:ok, true} -> {:ok, true}
      {:error, :user_does_not_exist} -> {:error, String.to_atom(prefix <> "_does_not_exist")}
      {:error, :too_many_requests_to_user} -> {:error, String.to_atom("too_many_requests_to_" <> prefix)}
    end
  end
end
