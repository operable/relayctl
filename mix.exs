defmodule Relayctl.Mixfile do
  use Mix.Project

  def project do
    [app: :relayctl,
     version: "0.2.0",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     escript: escript,
     aliases: aliases]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:getopt, github: "jcomellas/getopt", tag: "v0.8.2"}]
  end

  defp escript do
    [main_module: Relayctl,
     name: "relayctl",
     app: :relayctl,
     emu_args: "-noshell -hidden -name relayctl@127.0.0.1"]
  end

  defp aliases do
    ["escript": ["deps.get", "deps.compile", "escript.build"]]
  end

end
