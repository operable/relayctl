defmodule Relayctl.Optparse do
  require Logger

  @valid_actions [Relayctl.Actions.Bundles.List,
                  Relayctl.Actions.Bundles.Delete]

  def parse([arg]) when arg in ["--help", "-?"] do
    parse(nil)
  end
  def parse(args) when length(args) > 0 do
    case parse_action(args) do
      :nil ->
        IO.puts "Unable to parse '#{Enum.join(args, " ")}'"
        exit({:shutdown, 1})
      {handler, other_args} ->
        other_args = Enum.map(other_args, &String.to_char_list(&1))
        {name, specs} = opt_specs(handler)
        {:ok, {options, remaining}} = :getopt.parse(specs, other_args)
        case Enum.member?(options, :help) do
          true ->
            :getopt.usage(specs, name)
            :done
          false ->
            {handler, ensure_elixir_strings(options), ensure_elixir_strings(remaining)}
        end
    end
  end
  def parse(_) do
    actions = Enum.join(display_valid_actions, " | ")
    IO.puts "Usage: relayctl [#{actions}]"
    IO.puts "\n       relayctl <action> --help will display action specific help information."
    :done
  end

  defp parse_action(args) do
    handlers = handler_patterns()
    Enum.reduce(handlers, nil,
      fn(%{handler: handler, pattern: pattern}, nil) ->
        if starts_with?(args, pattern) do
          {handler, args -- pattern}
        else
          nil
        end
        (_handler, accum) -> accum
      end)
  end

  defp handler_patterns() do
    handlers = for handler <- @valid_actions do
      %{handler: handler, pattern: handler.name()}
    end
    Enum.sort(handlers, &(length(&1.pattern) > length(&2.pattern)))
  end

  defp display_valid_actions() do
    for handler <- @valid_actions do
      handler.display_name()
    end
  end

  defp opt_specs(handler) do
    name = String.to_char_list("relayctl " <> handler.display_name())
    specs = handler.option_spec()
    {name, global_opts(specs)}
  end

  defp global_opts(opts) do
    opts ++ [{:help, ??, 'help', :undefined, 'Displays this brief help'}]
  end
  defp ensure_elixir_strings(items) do
    ensure_elixir_strings(items, [])
  end

  defp ensure_elixir_strings([], accum) do
    Enum.reverse(accum)
  end
  defp ensure_elixir_strings([h|t], accum) when is_list(h) do
    ensure_elixir_strings(t, [String.Chars.List.to_string(h)|accum])
  end
  defp ensure_elixir_strings([{name, value}|t], accum) when is_list(value) do
    ensure_elixir_strings(t, [{name, String.Chars.List.to_string(value)}|accum])
  end
  defp ensure_elixir_strings([h|t], accum) do
    ensure_elixir_strings(t, [h|accum])
  end

  def starts_with?([data|dt], [pattern|pt]) when data == pattern do
    starts_with?(dt, pt)
  end
  def starts_with?(_data, []) do
    true
  end
  def starts_with?(_, _) do
    false
  end

end
