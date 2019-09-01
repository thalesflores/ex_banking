defmodule ExBanking do
  alias ExBanking.Server

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
      iex> create_user("name")
      :ok

      iex> create_user("name")
      {:error, :user_already_exists}
  """
  @spec create_user(user :: String.t()) :: :ok | banking_error
  def create_user(user), do: GenServer.start_link(Server, user, name: {:global, user})

  @doc """
    insert an amount of money to the given user and currency

    ## Params
      user: String
      amount: Float
      currency: String

    ## Examples

      iex> deposit("name", 10.50, "dolar")
      {:ok, 10.50}

      iex> deposit("names", 10.50, "dolar")
      {:error, :user_does_not_exist}
  """
  @spec deposit(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number} | banking_error
  def deposit(user, amount, currency) do
    GenServer.call({:global, user}, {:deposit, amount, currency})
  end

  @doc """
    remove an amount of money to the given user and currency

    ## Params
      user: String
      amount: Float
      currency: String

    ## Examples

      iex> withdraw("name", 35.0, "dolar")
      {:ok, 0.50}

      iex> withdraw("name", 100, "dolar")
      {:error, :not_enough_money}
  """
  @spec withdraw(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number} | banking_error
  def withdraw(user, amount, currency) do
  end

  @doc """
    returns the current balance to the givem user and currency

    ## Params
      user: String
      currency: String

    ## Examples

      iex> get_balance("name", "dolar")
      {:ok, 1000.0}

      iex> get_balance("names", "dolar")
      {:error, :user_does_not_exist}
  """
  @spec get_balance(user :: String.t(), currency :: String.t()) :: {:ok, balance :: number} | banking_error
  def get_balance(user, currency) do
  end

  @doc """
    transfers money between users.

    ## Params
      from_user: String
      to_user: String
      amount: Float
      currency: String

    ## Examples

      iex> send("name", "name2", "dolar", 100.0)
      {:ok, 1100.0, 900.0}

      iex> send("names", "name2", "dolar", 100.0)
      {:error, :sender_does_not_exist}
  """
  @spec send(
          from_user :: String.t(),
          to_user :: String.t(),
          amount :: number,
          currency :: String.t()
        ) :: {:ok, from_user_balance :: number, to_user_balance :: number} | banking_error
  def send(from_user, to_user, amount, currency) do
  end
end
