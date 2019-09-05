defmodule ExBanking.Accounts.BalanceTest do
  use ExUnit.Case, async: true
  alias ExBanking.Accounts.Balance

  @valid_balance [%Balance{amount: 100.00, currency: "dolar"}]

  describe "#deposit/3" do
    test "when passed new currency and returns currencies updated with new value" do
      balances = Balance.deposit(@valid_balance, 150.00, "real")

      assert is_list(balances) == true
      assert length(balances) == 2
      assert Balance.get_amount(balances, "real") == 150.00
      assert Balance.get_amount(balances, "dolar") == 100.00
    end

    test "when passed a currency that already exist and returns currencie updated with new value" do
      balances = Balance.deposit(@valid_balance, 150.00, "dolar")

      assert is_list(balances) == true
      assert length(balances) == 1
      assert Balance.get_amount(balances, "dolar") == 250.00
    end
  end

  describe "#withdraw/3" do
    test "when passed a available amount to withdraw and returns currencie updated with new value" do
      balances = Balance.withdraw(@valid_balance, 50.00, "dolar")

      assert is_list(balances) == true
      assert length(balances) == 1
      assert Balance.get_amount(balances, "dolar") == 50.00
    end

    test "when passed an amount higher than the available and returns error" do
      error = Balance.withdraw(@valid_balance, 101.00, "dolar")

      assert error == {:error, :not_enough_money}
      assert is_tuple(error) == true
    end

    test "when passed an currency that does not exist in balance and returns error" do
      error = Balance.withdraw(@valid_balance, 101.00, "real")

      assert error == {:error, :not_enough_money}
      assert is_tuple(error) == true
    end
  end

  describe "#get_amount/2" do
    test "when passed a currency that exist in balance and returns it amount" do
      amount = Balance.get_amount(@valid_balance, "dolar")

      assert is_float(amount) == true
      assert amount == 100.00
    end

    test "when passed an currency that does not exist in balance and returns amount zeroed" do
      amount = Balance.get_amount(@valid_balance, "real")

      assert is_float(amount) == true
      assert amount == 0.00
    end
  end
end
