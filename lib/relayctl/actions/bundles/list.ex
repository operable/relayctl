defmodule Relayctl.Actions.Bundles.List do
  @moduledoc """
  Lists all the bundles currently being run on this Relay.
  """

  use Relayctl.Action, "bundles list"
  require Relayctl.Connect
  alias Relayctl.Connect

  def option_spec, do: []

  def run(_options, _args) do
    case Connect.do_on_relay(Relay.Bundle.Catalog, :list_bundles, []) do
      bundles when is_list(bundles) ->
        bundles |> Enum.sort |> Enum.each(&IO.puts/1)
      error ->
        error
    end
  end

end
