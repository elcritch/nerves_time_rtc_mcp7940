defmodule NervesTime.RTC.mcp7940().TemperatureTest do
  use ExUnit.Case
  alias NervesTime.RTC.mcp7940().Temperature

  test "decode/1 and encode/1" do
    data = %{celsius: 25.25}
    bin = <<0b0001_1001>> <> <<0b0100_0000>>
    assert {:ok, data} == Temperature.decode(bin)
  end
end
