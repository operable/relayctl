defmodule Relayctl.Actions.Bundles.Delete do
  @moduledoc """
  Deletes a bundle from the Relay.
  """

  use Relayctl.Action, "bundle delete"
  require Logger
  require Relayctl.Connect
  alias Relayctl.Connect

  def option_spec, do: []

  def run(_options, [bundle_name]) do
    case Connect.do_on_relay(Relay.Bundle.InstallHelpers, :deactivate, [bundle_name]) do
      :ok ->
        :ok
      error ->
        error
    end
  end
  def run(_, _) do
    IO.puts(:stderr, "Invoke as `relayctl bundle delete <bundle_name>`")
    {:error, :invalid_invocation}
  end
end
