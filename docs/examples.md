# Examples

Workflow snippets for common setups.

> Replace `@1.0.0` with the [release version](https://github.com/Aeliot-Tm/todo-registrar-statistic-action/releases) you want to pin.

## Minimal workflow

```yaml
name: TODO statistic

on:
  pull_request:
    types: [opened, synchronize, reopened]

permissions:
  contents: read
  pull-requests: write

jobs:
  statistic:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      - uses: Aeliot-Tm/todo-registrar-statistic-action@1.0.0
```

## Custom config

Override `config` to limit which directories are scanned.
Start from the [built-in configuration](how-it-works.md#built-in-configuration)
and change `paths.in` (for example `/code/src`).

```yaml
  # ...
  - name: TODO statistic
    uses: Aeliot-Tm/todo-registrar-statistic-action@1.0.0
    with:
      config: |
        paths:
          in: .
          exclude:
            - tests/fixtures
            - var
            - vendor
        process:
          glueSameTickets: true
          glueSequentialComments: true
        registrar:
          type: DryRun
        tags:
          - todo
          - fixme
```

## Read outputs in a follow-up step

```yaml
      - name: TODO statistic
        id: statistic
        uses: Aeliot-Tm/todo-registrar-statistic-action@1.0.0

      - name: Log result
        run: |
          echo "Unregistered TODOs: ${{ steps.statistic.outputs.unregistered_count }}"
          echo "Comment ID: ${{ steps.statistic.outputs.comment_id }}"
```

## Related documentation

- [Inputs](inputs.md)
- [Permissions](permissions.md)
- [How it works](how-it-works.md)
