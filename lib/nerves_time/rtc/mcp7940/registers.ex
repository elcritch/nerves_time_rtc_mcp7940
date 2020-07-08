defmodule NervesTime.RTC.MCP7940.Registers do
  @registers %{
    address: 0x6F,
    rtcsec: 0x00,
    rtcmin: 0x01,
    rtchour: 0x02,
    rtcwkday: 0x03,
    rtcdate: 0x04,
    rtcmth: 0x05,
    rtcyear: 0x06,
    control: 0x07,
    osctrim: 0x08,
    alm0sec: 0x0A,
    alm0min: 0x0B,
    alm0hour: 0x0C,
    alm0wkday: 0x0D,
    alm0date: 0x0E,
    alm0mth: 0x0F,
    alm1sec: 0x11,
    alm1min: 0x12,
    alm1hour: 0x13,
    alm1wkday: 0x14,
    alm1date: 0x15,
    alm1mth: 0x16,
    pwrdnmin: 0x18,
    pwrdnhour: 0x19,
    pwrdndate: 0x1A,
    pwrdnmth: 0x1B,
    pwrupmin: 0x1C,
    pwruphour: 0x1D,
    pwrupdate: 0x1E,
    pwrupmth: 0x1F,
    ram_address: 0x20
  }

  def register(name), do: @registers[name]
  def registers(), do: @registers
end
