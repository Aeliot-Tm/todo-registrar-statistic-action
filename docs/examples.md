# Examples

Workflow snippets for common setups. Replace `@v1` with the [release version](https://github.com/Aeliot-Tm/todo-registrar-statistic-action/releases) you want to pin.

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
      - uses: Aeliot-Tm/todo-registrar-statistic-action@v1
```

## Custom scan paths

Override `config` to limit which directories are scanned. Start from the [built-in configuration](how-it-works.md#built-in-configuration) and change `paths.in` (for example `/code/src`).

## Post comments as the TODO Registrar bot

By default, the composite action posts with `GITHUB_TOKEN` and comments appear as `github-actions[bot]`.

To post as the `todo-registrar` GitHub App (no secrets in your repository):

1. [Install the TODO Registrar GitHub App](https://github.com/apps/todo-registrar) on your repository.
2. Call the reusable workflow instead of the composite action:

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
```

App credentials live only in the action repository secrets. Your workflow does not pass or store any token.

If you switch from `github-actions[bot]` to the app, delete the existing sticky comment once:
GitHub only allows the comment author to update it.

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
