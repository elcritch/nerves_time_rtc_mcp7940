defmodule NervesTime.RTC.MCP7940.Registers do
  @registers %{
    ADDRESS: 0x6F,
    RTCSEC: 0x00,
    RTCMIN: 0x01,
    RTCHOUR: 0x02,
    RTCWKDAY: 0x03,
    RTCDATE: 0x04,
    RTCMTH: 0x05,
    RTCYEAR: 0x06,
    CONTROL: 0x07,
    OSCTRIM: 0x08,
    ALM0SEC: 0x0A,
    ALM0MIN: 0x0B,
    ALM0HOUR: 0x0C,
    ALM0WKDAY: 0x0D,
    ALM0DATE: 0x0E,
    ALM0MTH: 0x0F,
    ALM1SEC: 0x11,
    ALM1MIN: 0x12,
    ALM1HOUR: 0x13,
    ALM1WKDAY: 0x14,
    ALM1DATE: 0x15,
    ALM1MTH: 0x16,
    PWRDNMIN: 0x18,
    PWRDNHOUR: 0x19,
    PWRDNDATE: 0x1A,
    PWRDNMTH: 0x1B,
    PWRUPMIN: 0x1C,
    PWRUPHOUR: 0x1D,
    PWRUPDATE: 0x1E,
    PWRUPMTH: 0x1F,
    RAM_ADDRESS: 0x20
  }

  def name(nm), do: @registers[nm]
  def registers(), do: @registers
end
