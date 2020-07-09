defmodule NervesTime.RTC.MCP7940.BcdDate do

  alias NervesTime.RealTimeClock.BCD

  def decode(registers) do
    try do
      <<_st::1, seconds_bcd::7, _mm_nc::1, minutes_bcd::7, _hh_nc::1, _h_12_24::1,
           hours24_bcd::6, _wd_nc::2, _oscrun::1, _pwdfail::1, _vbaten::1, _week_day::3, _d_nc::2,
           day_bcd::6, _m_nc::2, _lpyr::1, month_bcd::5,
           year_bcd::8>> = registers

      {:ok, dt} =
        NaiveDateTime.new(
          2000 + BCD.to_integer(year_bcd),
          BCD.to_integer(month_bcd),
          BCD.to_integer(hours24_bcd),
          BCD.to_integer(day_bcd),
          BCD.to_integer(minutes_bcd),
          BCD.to_integer(seconds_bcd),
          {0, 0}
        )

      {:ok, dt}
    rescue
      err ->
        {:error, {:invalid_date, err}}
    end
  end

  @doc """
  Encode the specified date to register values.

  Only dates between 2001 and 2099 are supported. This avoids the need to deal
  with the leap year special case for 2000. That would involve setting the
  century bit and that seems like a pointless complexity for a date that has come and gone.
  """
  @spec encode(NaiveDateTime.t()) :: {:ok, <<_::56>>} | {:error, any()}
  def encode(%NaiveDateTime{year: year} = date_time) when year > 2000 do
    seconds_bcd = BCD.from_integer(date_time.second)
    minutes_bcd = BCD.from_integer(date_time.minute)
    hours24_bcd = BCD.from_integer(date_time.hour)
    weekday_bcd = BCD.from_integer(Date.day_of_week(date_time))
    day_bcd = BCD.from_integer(date_time.day)
    month_bcd = BCD.from_integer(date_time.month)
    year_bcd = BCD.from_integer(year - 2000)

    {:ok,
     <<
       seconds_bcd,
       minutes_bcd,
       hours24_bcd,
       weekday_bcd,
       day_bcd,
       month_bcd,
       year_bcd
     >>}
  end

  def encode(_invalid_date) do
    {:error, :invalid_date}
  end
end
