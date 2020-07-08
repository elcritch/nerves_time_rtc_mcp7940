defmodule NervesTime.RTC.MCP7940 do
  @moduledoc """
  Abracon RTC implementation for NervesTime

  To configure NervesTime to use this module, update the `:nerves_time` application
  environment like this:

  ```elixir
  config :nerves_time, rtc: NervesTime.RTC.Abracon
  ```

  If not using `"i2c-1"` or the default I2C bus address, specify them like this:

  ```elixir
  config :nerves_time, rtc: {NervesTime.RTC.Abracon, [bus_name: "i2c-2", address: 0x69]}
  ```

  Check the logs for error messages if the RTC doesn't appear to work.

  See https://abracon.com/Support/AppsManuals/Precisiontiming/Application%20Manual%20AB-RTCMC-32.768kHz-IBO5-S3.pdf
  for implementation details.
  """

  @behaviour NervesTime.RealTimeClock

  require Logger

  alias Circuits.I2C
  alias NervesTime.RTC.MCP7940.Registers
  alias NervesTime.RTC.MCP7940.Date
  alias NervesTime.RTC.MCP7940.Control

  @default_bus_name "i2c-1"
  @default_address 0x6F

  @typedoc false
  @type state :: %{
          i2c: I2C.bus(),
          bus_name: String.t(),
          address: I2C.address()
        }

  @impl NervesTime.RealTimeClock
  def init(args) do
    bus_name = Keyword.get(args, :bus_name, @default_bus_name)
    address = Keyword.get(args, :address, @default_address)

    with {:ok, i2c} <- I2C.open(bus_name),
         :ok <- Control.deviceStart(i2c, address) do
      {:ok, %{i2c: i2c, bus_name: bus_name, address: address}}
    end
  end

  @impl NervesTime.RealTimeClock
  def terminate(_state), do: :ok

  @impl NervesTime.RealTimeClock
  def set_time(%{address: address, i2c: i2c} =  state, now) do
    with {:ok, registers} <- Date.encode(now),
         :ok <- Control.deviceStop(i2c, address),
         :ok <- I2C.write(i2c, address, [<<Registers.name(:RTCSEC)>>, registers] ),
         :ok <- Control.deviceStart(i2c, address)
    do
      state
    else
      error ->
        _ = Logger.error("Error setting Abracon RTC to #{inspect(now)}: #{inspect(error)}")
        state
    end
  end

  @impl NervesTime.RealTimeClock
  def get_time(state) do
    with {:ok, registers} <- I2C.write_read(state.i2c, state.address, <<Registers.name(:RTCSEC)>>, 7),
         {:ok, time} <- Date.decode(registers) do
      {:ok, time, state}
    else
      any_error ->
        _ = Logger.error("Abracon RTC not set or has an error: #{inspect(any_error)}")
        {:unset, state}
    end
  end

end
