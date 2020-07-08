defmodule NervesTime.RTC.mcp7940.Status do
  @moduledoc false

  alias NervesTime.RTC.mcp7940

  @typedoc "The mcp7940 status registers are a 1-byte binary."
  @type registers :: <<_::8>>

  @typedoc "The shape of the status registers after decoding them."
  @type data :: %{
          osc_stop_flag: mcp7940.flag(),
          busy: mcp7940.flag(),
          ena_32khz_out: mcp7940.flag(),
          alarm_2_flag: mcp7940.flag(),
          alarm_1_flag: mcp7940.flag()
        }

  @doc """
  Return a list of commands for reading the Status register
  """
  def reads() do
    # Register 0x0f
    [{:write_read, <<0x0F>>, 1}]
  end

  @spec decode(registers()) :: {:ok, map()} | {:error, any()}
  def decode(
        <<osc_stop_flag::size(1), _::size(3), ena_32khz_out::size(1), busy::size(1),
          alarm_2_flag::size(1), alarm_1_flag::size(1)>>
      ) do
    data = %{
      osc_stop_flag: osc_stop_flag,
      busy: busy,
      ena_32khz_out: ena_32khz_out,
      alarm_2_flag: alarm_2_flag,
      alarm_1_flag: alarm_1_flag
    }

    {:ok, data}
  end

  def decode(_other), do: {:error, :invalid}

  @spec encode(data()) :: {:ok, registers()}
  def encode(%{
        osc_stop_flag: osc_stop_flag,
        busy: busy,
        ena_32khz_out: ena_32khz_out,
        alarm_2_flag: alarm_2_flag,
        alarm_1_flag: alarm_1_flag
      }) do
    bin =
      <<osc_stop_flag::size(1), 0::size(3), ena_32khz_out::size(1), busy::size(1),
        alarm_2_flag::size(1), alarm_1_flag::size(1)>>

    {:ok, bin}
  end

  def encode(_), do: {:error, :invalid}
end
