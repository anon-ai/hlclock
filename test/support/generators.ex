defmodule HLClock.Generators do
  import StreamData

  alias HLClock.Timestamp

  @max_node_size 18_446_744_073_709_551_615
  @max_counter_size 65_535
  @max_time_size 281_474_976_710_655
  @max_time_value 253_402_300_799_999 # 9999-12-31T23:59:59.999Z

  def ntp_millis, do: integer(0..@max_time_size)

  def int_of_size(size) do
    bind(bitstring(length: size), fn(<<n :: integer-size(size)>>) ->
      constant(n)
    end)
  end

  def timestamp do
    gen all time <- integer(0..max_time_value()),
            counter <- integer(0..max_counter()),
            node_id <- integer(0..max_node()) do
      {:ok, timestamp} = Timestamp.new(time, counter, node_id)
      timestamp
    end
  end

  def large_time, do: large_integer(max_time_size())
  def large_node_id, do: large_integer(max_node())
  def large_counter, do: large_integer(max_counter())

  def large_integer(value), do: integer((value+1)..(value*2))

  def max_node, do: @max_node_size
  def max_time_size, do: @max_time_size
  def max_time_value, do: @max_time_value
  def max_counter, do: @max_counter_size
end
