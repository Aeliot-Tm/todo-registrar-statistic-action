# Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `config` | No | built-in | Inline YAML configuration for [TODO Registrar](https://github.com/Aeliot-Tm/todo-registrar). If empty, scans `/code` with the built-in default |
| `verbosity` | No | `normal` | Verbosity level: `quiet`, `normal`, `verbose`, `very-verbose`, `debug` |
| `github_token` | No | `GITHUB_TOKEN` | Token for posting PR comments. The reusable workflow passes a GitHub App token; leave empty when using the composite action directly |

> `config_path` is **not** supported. The action must run on a `pull_request` event.

## Built-in default

When `config` is omitted, the action scans the entire checked-out repository. No tracker credentials are required.

## Custom configuration

Pass inline YAML to change scan paths, tags, or processing rules. Use the same overall shape as the [built-in default](how-it-works.md#built-in-configuration) in How it works — typically only `paths` needs to change.

## Related documentation

- [Examples](examples.md)
- [How it works](how-it-works.md)
- [TODO Registrar configuration](https://github.com/Aeliot-Tm/todo-registrar/blob/main/docs/config/general_config_yaml.md)
