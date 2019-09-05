defmodule ExBankingTest do
  use ExUnit.Case, async: true

  setup do
    Application.stop(:ex_banking)
    Application.start(:ex_banking)
    :ok
  end

  @valid_user "New User"
  @valid_user2 "Another New User"
  @invalid_user []
  @valid_amount 100.00
  @invalid_amount -100.00
  @valid_currency "dolar"
  @invalid_currency []

  describe "#create_user/1" do
    test "when passend valid user and returns success" do
      assert ExBanking.create_user(@valid_user) == :ok
    end

    test "when passend invalid user and returns error" do
      assert ExBanking.create_user(@invalid_user) == {:error, :wrong_arguments}
    end

    test "when passed a user that already exists and returns error" do
      ExBanking.create_user(@valid_user)

      assert assert ExBanking.create_user(@valid_user) == {:error, :user_already_exists}
    end
  end

  describe "#deposit/3" do
    setup do
      ExBanking.create_user(@valid_user)
    end

    test "when passed valid argumetens and returns new balace" do
      assert {:ok, 100.00} = ExBanking.deposit(@valid_user, @valid_amount, @valid_currency)
      assert {:ok, 100.00} = ExBanking.get_balance(@valid_user, @valid_currency)
    end

    test "when passed a nonexistent user and return error" do
      assert {:error, :user_does_not_exist} = ExBanking.deposit(@valid_user2, @valid_amount, @valid_currency)
    end

    test "when passed an invalid argument and returns error" do
      assert {:error, :wrong_arguments} = ExBanking.deposit(@invalid_user, @valid_amount, @valid_currency)
      assert {:error, :wrong_arguments} = ExBanking.deposit(@valid_user, @invalid_amount, @valid_currency)
      assert {:error, :wrong_arguments} = ExBanking.deposit(@valid_user2, @valid_amount, @invalid_currency)
    end
  end

  describe "#withdraw/3" do
    setup do
      ExBanking.create_user(@valid_user)
      ExBanking.deposit(@valid_user, @valid_amount, @valid_currency)
      :ok
    end

    test "when passed valid arguments and available amount and returns success" do
      assert {:ok, 50.00} == ExBanking.withdraw(@valid_user, 50.00, @valid_currency)
      assert {:ok, 50.00} == ExBanking.get_balance(@valid_user, @valid_currency)
    end

    test "when passed a valid arguments but an unavailable amount and returns error" do
      assert {:error, :not_enough_money} == ExBanking.withdraw(@valid_user, @valid_amount + 1, @valid_currency)
    end

    test "when passed an nonexistent currency and returns error" do
      assert {:error, :not_enough_money} == ExBanking.withdraw(@valid_user, @valid_amount, "real")
    end

    test "when passed invalid arguments and return errror" do
      assert {:error, :wrong_arguments} = ExBanking.withdraw(@invalid_user, @valid_amount, @valid_currency)
      assert {:error, :wrong_arguments} = ExBanking.withdraw(@valid_user, @invalid_amount, @valid_currency)
      assert {:error, :wrong_arguments} = ExBanking.withdraw(@valid_user2, @valid_amount, @invalid_currency)
    end

    test "when passed nonexistent user and returns error" do
      assert {:error, :user_does_not_exist} = ExBanking.withdraw(@valid_user2, @valid_amount, @valid_currency)
    end
  end

  describe "#get_balance/2" do
    setup do
      ExBanking.create_user(@valid_user)
      ExBanking.deposit(@valid_user, @valid_amount, @valid_currency)
      :ok
    end

    test "when passed valid arguments and returns success" do
      assert {:ok, @valid_amount} == ExBanking.get_balance(@valid_user, @valid_currency)
    end

    test "when passed valid arguments but a non nonexistent currency and returns success with zeroed amount" do
      assert {:ok, 0.00} == ExBanking.get_balance(@valid_user, "real")
    end

    test "when passed invalid arguments and return errror" do
      assert {:error, :wrong_arguments} = ExBanking.get_balance(@invalid_user, @valid_currency)
      assert {:error, :wrong_arguments} = ExBanking.get_balance(@valid_user, @invalid_currency)
    end

    test "when passed nonexistent user and returns error" do
      assert {:error, :user_does_not_exist} = ExBanking.get_balance(@valid_user2, @valid_currency)
    end
  end

  describe "#send/4" do
    setup do
      ExBanking.create_user(@valid_user)
      ExBanking.create_user(@valid_user2)
      ExBanking.deposit(@valid_user, @valid_amount, @valid_currency)
      ExBanking.deposit(@valid_user2, @valid_amount, @valid_currency)
      :ok
    end

    test "when passed valid arguments and returns balances updated and success" do
      assert {:ok, 49.99, 150.01} = ExBanking.send(@valid_user, @valid_user2, 50.01, @valid_currency)
      assert {:ok, 49.99} = ExBanking.get_balance(@valid_user, @valid_currency)
      assert {:ok, 150.01} = ExBanking.get_balance(@valid_user2, @valid_currency)
    end

    test "when passed a total amount higher than the balance and returns error" do
      assert {:error, :not_enough_money} = ExBanking.send(@valid_user, @valid_user2, 100.01, @valid_currency)
    end

    test "when passed an invalid sender and returns error" do
      assert {:error, :sender_does_not_exist} = ExBanking.send("wrong user", @valid_user2, 50.00, @valid_currency)
    end

    test "when passed an invalid receiver and returns error" do
      assert {:error, :receiver_does_not_exist} = ExBanking.send(@valid_user, "wrong user", 50.00, @valid_currency)
    end

    test "when passed wrong arguments and returns error" do
      assert {:error, :wrong_arguments} = ExBanking.send(@invalid_user, @valid_user2, 100.00, @valid_currency)
      assert {:error, :wrong_arguments} = ExBanking.send(@valid_user, @invalid_user, 100.00, @valid_currency)
      assert {:error, :wrong_arguments} = ExBanking.send(@valid_user, @valid_user2, @invalid_amount, @valid_currency)
      assert {:error, :wrong_arguments} = ExBanking.send(@valid_user, @valid_user2, 100.00, @invalid_currency)
    end
  end
end
