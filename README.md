# Relayctl

CLI tool for interacting with [Relay](https://github.com/operable/relay) instances.

## Building

Use [mix](http://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html), Elixir's build tool, to generate a `relayctl` executable in the current directory.

```sh
mix escript
```

## Running `relayctl`

Note that `relayctl` must be run on the same host on which the Relay instance you're interacting with is running.

`relayctl` has subcommands that carry out its actions. To find out all the subcommands that are available, run

```sh
relayctl --help
```

### `bundles list` Command

List all bundles currently being served by the Relay.
```sh
relayctl bundles list
```
### `bundles delete` Command

Delete the named bundle from the Relay. It does not affect other Relay instances that may be running the same bundle, nor does it delete the bundle or any custom rules associated with it from the Cog bot. It simply stops _this_ Relay from serving it anymore.

```sh
relayctl bundles delete $BUNDLE_NAME
```

## Filing issues

relayctl issues are tracked centrally in [Cog's](https://github.com/operable/cog/issues) issue tracker.
