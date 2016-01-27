defmodule Relayctl.Actions.Bundles.Delete do
  @moduledoc """
  Deletes a bundle from the Relay.
  """

  use Relayctl.Action, "bundles delete"
  require Relayctl.Connect
  alias Relayctl.Connect

  def option_spec, do: [
    {:bundle, :undefined, :undefined, :string, 'Name of bundle to delete (required)'},
  ]

  def run([{:bundle, bundle_name}], _),
    do: Connect.do_on_relay(Relay.Bundle.InstallHelpers, :deactivate, [bundle_name])
  def run(_options, _args) do
    IO.puts(:stderr, "Error: missing required argument")
    :error
  end
end
