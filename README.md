# NervesTime.RTC.mcp7940

[![CircleCI](https://circleci.com/gh/nerves-time/nerves_time_rtc_mcp7940.svg?style=svg)](https://circleci.com/gh/nerves-time/nerves_time_rtc_mcp7940)
[![Hex version](https://img.shields.io/hexpm/v/nerves_time_rtc_mcp7940.svg "Hex version")](https://hex.pm/packages/nerves_time_rtc_mcp7940)

NervesTime.RTC implementation for popular Maxim Integrated Extremely Accurate
Real-Time Clock chip with TCXO.  [An "Oldie-but-Goodie". Dallas Semiconductor
was acquired by Maxim in 2001]

Features of the mcp7940 device other than the time and date registers  [i.e.
Alarms, Interrupts, Square Wave output and Temperature measurement]  are
untouched by this plugin, and are therefore available to other user-written
Elixir apps.

The following are supported:

* [mcp7940](https://datasheets.maximintegrated.com/en/ds/mcp7940.pdf)

## Using

First add this project to your `mix` dependencies:

```elixir
def deps do
  [
    {:nerves_time_rtc_mcp7940, "~> 0.1.0"}
  ]
end
```

And then update your `:nerves_time` configuration to point to it:

```elixir
config :nerves_time, rtc: NervesTime.RTC.mcp7940
```

It's possible to override the default I2C bus and address via options:

```elixir
config :nerves_time, rtc: {NervesTime.RTC.mcp7940, [bus_name: "i2c-2", address:
0x69]}
```

Check the logs for error messages if the RTC doesn't appear to work.
