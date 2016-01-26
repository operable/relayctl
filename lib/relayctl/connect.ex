defmodule Relayctl.Connect do
  @moduledoc """
  Handles the details of connecting to and properly executing
  functions on a remote Relay node.

  All `relayctl` commands interact directly with the running Relay
  process on the same host using distributed Erlang (because Relay
  does not expose an API like Cog does).
  """

  # Relay nodes all run with this name; it is how we address the
  # node using distributed Erlang.
  @node_name :"relay@127.0.0.1"

  @doc """
  Execute the specified function on the Relay node running on the
  host.

  Manages the connection to Relay using distributed Erlang, as well as
  ensuring the group leader is set appropriately so that logging
  messages appear in Relay's logs, and not in the caller's terminal.
  """
  defmacro do_on_relay(module, function, arguments) do
    # Really, the only reason this is a macro is to capture where it's
    # being called from for more helpful error messages.
    {caller_fun, caller_arity} = __CALLER__.function
    caller = "#{inspect __CALLER__.module}.#{caller_fun}/#{caller_arity}"

    quote bind_quoted: [m: module,
                        f: function,
                        a: arguments,
                        caller: caller,
                        relay_node: @node_name] do
      case Node.connect(relay_node) do
        true ->
          # Grab the group leader on the Relay node, as well as
          # Relayctl's group leader on this node; we'll need that in
          # order to swap group leaders after the RPC call.
          relay_leader = Relayctl.Connect.remote_group_leader(relay_node)
          original_leader = Relayctl.Connect.local_group_leader

          # Make sure Relay logging messages stay in Relay's logs
          Relayctl.Connect.set_group_leader(relay_leader)
          try do
            case :rpc.call(relay_node, m, f, a) do
              {:badrpc, error} ->
                Relayctl.Connect.set_group_leader(original_leader)
                IO.puts(:stderr, "Bad RPC in #{caller}")
                {:error, error}
              value ->
                Relayctl.Connect.set_group_leader(original_leader)
                value
            end
          rescue
            e in RuntimeError ->
              Relayctl.Connect.set_group_leader(original_leader)
              IO.puts(:stderr, "#{inspect e}")
              {:error, e}
          end
        _ ->
          IO.puts(:stderr, """
          You must run `relayctl` from the same host running the Relay
          instance you wish to manipulate.

          If you are on the proper host, please ensure that Relay is
          running.
          """)
          exit({:shutdown, 1})
      end
    end
  end

  @doc """
  Find the group leader on `node`. Depends on a distributed
  Erlang connection to `node` already existing.
  """
  def remote_group_leader(node),
    do: :rpc.call(node, :erlang, :whereis, [:user])

  @doc """
  Find the current group leader of this Erlang node.
  """
  def local_group_leader,
    do: :erlang.whereis(:user)

  @doc """
  Sets the group leader of this Erlang node to `new_leader`.
  """
  def set_group_leader(new_leader) when is_pid(new_leader),
    do: :erlang.group_leader(new_leader, self())

end
