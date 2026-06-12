# Examples

Workflow snippets for common setups. Replace `@v1` with the [release version](https://github.com/Aeliot-Tm/todo-registrar-statistic-action/releases) you want to pin.

## Post comments as the TODO Registrar bot (recommended)

1. [Install the TODO Registrar GitHub App](https://github.com/apps/todo-registrar) on your repository.
2. Use the reusable workflow:

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
    uses: Aeliot-Tm/todo-registrar-statistic-action/.github/workflows/statistic.yaml@v1
    with:
      config: |
        paths:
          in: /code
```

## Minimal workflow (composite action)

Posts as `github-actions[bot]`. For `todo-registrar[bot]`, use the reusable workflow above.

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
      - uses: Aeliot-Tm/todo-registrar-statistic-action@v1
```

## Custom scan paths

Override `config` to limit which directories are scanned. Start from the [built-in configuration](how-it-works.md#built-in-configuration) and change `paths.in` (for example `/code/src`).

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
