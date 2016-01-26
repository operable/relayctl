defmodule Relayctl do

  def main(args) do
    case Relayctl.Optparse.parse(args) do
      :done ->
        :ok
      {handler, options, remaining} ->
        case handler.run(options, remaining) do
          :ok ->
            :ok
          :error ->
            exit({:shutdown, 1})
          error ->
            display_error(error)
        end
      error ->
        display_error(error)
    end
  end

  defp display_error(error) do
    IO.puts "Error: #{inspect error}"
    exit({:shutdown, 1})
  end


end
