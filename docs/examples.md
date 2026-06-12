# Examples

Workflow snippets for common setups. Replace `@v1` with the [release version](https://github.com/Aeliot-Tm/todo-registrar-statistic-action/releases) you want to pin.

## Post comments as the TODO Registrar bot (recommended)

1. [Install the TODO Registrar GitHub App](https://github.com/apps/todo-registrar) on your repository.
2. Use the composite action:

```yaml
name: TODO statistic

on:
  pull_request:
    types: [opened, synchronize, reopened]

permissions:
  contents: read
  pull-requests: write
  id-token: write

jobs:
  statistic:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      - uses: Aeliot-Tm/todo-registrar-statistic-action@v1
        with:
          config: |
            paths:
              in: /code
```

## Minimal workflow

```yaml
name: TODO statistic

on:
  pull_request:
    types: [opened, synchronize, reopened]

permissions:
  contents: read
  pull-requests: write
  id-token: write

jobs:
  statistic:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      - uses: Aeliot-Tm/todo-registrar-statistic-action@v1
```

## Post as `github-actions[bot]`

```yaml
      - uses: Aeliot-Tm/todo-registrar-statistic-action@v1
        with:
          post_as_app: false
```

## Custom scan paths

Override `config` to limit which directories are scanned. Start from the [built-in configuration](how-it-works.md#built-in-configuration)
and change `paths.in` (for example `/code/src`).

## Read outputs in a follow-up step

```yaml
      - name: TODO statistic
        id: statistic
        uses: Aeliot-Tm/todo-registrar-statistic-action@v1

      - name: Log result
        run: |
          echo "Unregistered TODOs: ${{ steps.statistic.outputs.unregistered_count }}"
          echo "Comment ID: ${{ steps.statistic.outputs.comment_id }}"
```

## Related documentation

- [Inputs](inputs.md)
- [Permissions](permissions.md)
- [How it works](how-it-works.md)
- [GitHub App](github-app.md)
