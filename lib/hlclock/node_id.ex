defmodule HLClock.NodeId do
  require Logger

  use Bitwise, only_operators: true

  def hash(name \\ Node.self()) do
    name
    |> Atom.to_string
    |> :erlang.phash2
  end

  def lookup() do
    load_node_id() |> validate_node_id()
  end

  defp load_node_id() do
    env() || hw()
  end

  def env() do
    Application.get_env(:hlclock, :node_id)
  end

  def hw() do
    :inet.getifaddrs() |> filter_ifaddrs()
  end

  defp validate_node_id(:error) do
    invalid_node_id!()
  end

  defp validate_node_id(nil) do
    invalid_node_id!()
  end

  defp validate_node_id({:system, var_name}) do
    System.get_env(var_name) |> validate_node_id()
  end

  defp validate_node_id({node_id, _binary}) when is_integer(node_id) do
    node_id
  end

  defp validate_node_id(node_id) when is_binary(node_id) do
    node_id |> Integer.parse() |> validate_node_id()
  end

  defp validate_node_id(node_id) when is_integer(node_id) do
    node_id
  end

  defp validate_node_id(node_id) do
    invalid_node_id!()
  end

  defp invalid_node_id!() do
    raise "Invalid node_id configured for :hlclock"
  end

  defp filter_ifaddrs({:ok, addrs}) do
    addrs
    |> Enum.filter(&is_valid_ifaddr?/1)
    |> node_id_from_if()
  end

  defp is_valid_ifaddr?({'lo', _}) do
    false
  end

  defp is_valid_ifaddr?({_, attrs}) do
    case Keyword.get(attrs, :hwaddr) do
      [0, 0, 0, 0, 0, 0] ->
        false
      [_, _, _, _, _, _] ->
        true
      _ ->
        false
    end
  end

  defp node_id_from_if([{dev, attrs} | _]) do
    Logger.info("#{__MODULE__} getting id from network interface #{dev}...")
    [a, b, c, d, e, f] = Keyword.fetch!(attrs, :hwaddr)
    (a <<< 40) + (b <<< 32) + (c <<< 24) + (d <<< 16) + (e <<< 8) + f
  end
end
