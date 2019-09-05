defmodule ExBanking.OperationsTest do
  use ExUnit.Case, async: true
  alias ExBanking.Operations

  describe "#sum/2" do
    test "when passed numbers and returs an number as result" do
      assert Operations.sum(1, 1.50) == 2.50
    end
  end

  describe "#sub/2" do
    test "when passed numbers and returs an number as result" do
      assert Operations.sub(1, 0.50) == 0.50
    end
  end

  describe "#round_amount/" do
    test "when passed number and returs it as float" do
      assert Operations.round_amount(1) == 1.00
      assert is_float(Operations.round_amount(1)) == true
    end
  end
end
