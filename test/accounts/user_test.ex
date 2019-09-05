defmodule ExBanking.Accounts.UserTest do
  use ExUnit.Case, async: true

  setup do
    Application.stop(:ex_banking)
    Application.start(:ex_banking)
    :ok
  end

  describe "#available?/1" do
    test "when user is available to the request" do
      ExBanking.create_user("New User")
      assert {:ok, true} == ExBanking.Accounts.User.available?("New User")
    end

    test "when passed wrong user and it is unavailable" do
      assert {:error, :user_does_not_exist} == ExBanking.Accounts.User.available?("New User")
    end

    test "when there are too many requests to the same user an it is unavailable" do
      ExBanking.create_user("New User")

      error_response =
        Enum.reduce(0..1000, [], fn _requests, acc ->
          [Task.async(fn -> ExBanking.deposit("New User", 100, "dolar") end) | acc]
        end)
        |> Enum.map(&Task.await/1)
        |> Enum.filter(fn {status, _msg} -> :error == status end)
        |> List.first()

      assert error_response == {:error, :too_many_requests_to_user}
    end
  end
end
