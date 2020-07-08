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
         :ok <- probe(i2c, address) do
      {:ok, %{i2c: i2c, bus_name: bus_name, address: address}}
    end
  end

  @impl NervesTime.RealTimeClock
  def terminate(_state), do: :ok

  @impl NervesTime.RealTimeClock
  def set_time(state, now) do
    with {:ok, registers} <- Date.encode(now),
         :ok <- I2C.write(state.i2c, state.address, [0, registers]) do
      state
    else
      error ->
        _ = Logger.error("Error setting Abracon RTC to #{inspect(now)}: #{inspect(error)}")
        state
    end
  end

  @impl NervesTime.RealTimeClock
  def get_time(state) do
    with {:ok, registers} <- I2C.write_read(state.i2c, state.address, <<0>>, 7),
         {:ok, time} <- Date.decode(registers) do
      {:ok, time, state}
    else
      any_error ->
        _ = Logger.error("Abracon RTC not set or has an error: #{inspect(any_error)}")
        {:unset, state}
    end
  end

  @spec probe(I2C.bus(), I2C.address()) :: :ok | {:error, String.t()}
  defp probe(i2c, address) do
    with {:ok, rtset} <- I2C.write_read(i2c, address, <<Registers.name(:rtcsec)>>, 1),
         << _st::1, secs::7>> <- rtset,
         :ok <- I2C.write(i2c, address, <<Registers.name(:RTCSEC), 1::1, secs::7>>),
         {:ok, rtset!} <- I2C.write_read(i2c, address, <<Registers.name(:RTCSEC)>>, 1),
         << st!::1, _secs!::7>> <- rtset!
    do
      if st! == 1 do
        check_oscrun(i2c, address, 100)
      else
        {:error, "RTC not enabling at #{address}, RTCSEC register: #{inspect rtset!}"}
      end
    else
      _err ->
        {:error, "RTC not found at #{address}"}
    end
  end

  defp check_oscrun(_i2c, _address, 0) do
    {:error, "RTC oscillator not running?! "}
  end
  defp check_oscrun(i2c, address, retries) do
    {:ok, rtcwkday} = I2C.write_read(i2c, address, <<Registers.name(:RTCWKDAY)>>, 1)
    << _dc::2, oscrun::1, _wkday::5 >> = rtcwkday

    if oscrun == 1 do
      :ok
    else
      Process.sleep(1)
      check_oscrun(i2c, address, retries - 1)
    end
  end
end
