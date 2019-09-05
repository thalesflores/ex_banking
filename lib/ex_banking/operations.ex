defmodule ExBanking.Operations do
  @spec add(number, number) :: number
  def add(num1, num2), do: num1 + num2

  @spec sub(number, number) :: number
  def sub(num1, num2), do: num1 - num2

  @spec round_amount(amount :: number) :: float()
  def round_amount(amount) do
    case is_integer(amount) do
      true -> (amount / 1) |> Float.round(2)
      _ -> Float.round(amount, 2)
    end
  end
end
