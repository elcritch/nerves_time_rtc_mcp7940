defmodule NervesTime.RTC.MCP7940.Control do
  @moduledoc false
  require Logger

  alias Circuits.I2C
  alias NervesTime.RTC.MCP7940.Registers

  # @vbat_en 1 <<< 3
  @vbat_en 1

  @spec deviceStart(I2C.bus(), I2C.address()) :: :ok | {:error, String.t()}
  def deviceStart(i2c, address) do
    deviceHandle(i2c, address, 1)

    # writeRegisterBit(MCP7940_RTCWKDAY, MCP7940_VBATEN, state);

    # :ok <- I2C.write(i2c, address, [<<Registers.name(:RTCWKDAY)>>, <<st_bit::1, secs::7>>]),

    with {:ok, wkday} <- I2C.write_read(i2c, address, <<Registers.name(:RTCWKDAY)>>, 1),
         <<wd_nc::2, oscrun::1, pwdfail::1, _v_en::1, week_day::3>> <- wkday,
         wkday! <- <<wd_nc::2, oscrun::1, pwdfail::1, @vbat_en::1, week_day::3>>,
         :ok <- I2C.write(i2c, address, [<<Registers.name(:RTCWKDAY)>>, wkday!]),
         {:ok, ^wkday!} <- I2C.write_read(i2c, address, <<Registers.name(:RTCWKDAY)>>, 1) do
      :ok
    else
      _err ->
        {:error, "RTC not found at #{address}"}
    end
  end

  @spec deviceStop(I2C.bus(), I2C.address()) :: :ok | {:error, String.t()}
  def deviceStop(i2c, address) do
    deviceHandle(i2c, address, 0)
  end

  @spec deviceHandle(I2C.bus(), I2C.address(), 0 | 1) :: :ok | {:error, String.t()}
  def deviceHandle(i2c, address, st_bit) do
    with {:ok, rtset} <- I2C.write_read(i2c, address, <<Registers.name(:RTCSEC)>>, 1),
         <<_st::1, secs::7>> <- rtset,
         :ok <- I2C.write(i2c, address, [<<Registers.name(:RTCSEC)>>, <<st_bit::1, secs::7>>]),
         {:ok, rtset!} <- I2C.write_read(i2c, address, <<Registers.name(:RTCSEC)>>, 1),
         <<st!::1, _secs!::7>> <- rtset! do
      if st! == st_bit do
        check_oscrun(i2c, address, 100, st_bit)
      else
        {:error, "RTC not enabling at #{address}, RTCSEC register: #{inspect(rtset!)}"}
      end
    else
      _err ->
        {:error, "RTC not found at #{address}"}
    end
  end

  defp check_oscrun(_i2c, _address, 0, _st_bit) do
    {:error, "RTC oscillator not running?! "}
  end

  defp check_oscrun(i2c, address, retries, st_bit) do
    {:ok, rtcwkday} = I2C.write_read(i2c, address, <<Registers.name(:RTCWKDAY)>>, 1)
    <<_dc::2, oscrun::1, _wkday::5>> = rtcwkday

    # Logger.warn("OSCRUN: #{inspect oscrun} (0b#{wkday |> Integer.to_string(2)})")

    if oscrun == st_bit do
      :ok
    else
      Process.sleep(1)
      check_oscrun(i2c, address, retries - 1, st_bit)
    end
  end
end
