![logo.svg](docs/logo.svg)

[![Testing](https://github.com/Aeliot-Tm/todo-registrar-statistic-action/actions/workflows/automated-testing.yaml/badge.svg?branch=main)](https://github.com/Aeliot-Tm/todo-registrar-statistic-action/actions/workflows/automated-testing.yaml?query=branch%3Amain)
[![GitHub License](https://img.shields.io/github/license/Aeliot-Tm/todo-registrar-statistic-action?label=License)](LICENSE)

# TODO Registrar Statistic Action

GitHub Action that scans a pull request branch for unregistered TODO comments and posts a sticky summary comment on the pull request.

No issue tracker credentials are required. The action does not create tickets or modify source files.

### Features

- Scans the repository and counts TODO comments without an issue key.
- Sticky PR comment updated on each push (found by HTML marker, not comment position).
- Summary of unregistered TODOs with per-file breakdown.
- Posts as **`todo-registrar[bot]`** when the GitHub App is installed (no workflow secrets in consumer repos).
- Always succeeds; reports when no unregistered TODOs are found.

## Quick start

1. [Install the TODO Registrar GitHub App](https://github.com/apps/todo-registrar) on your repository.
2. Create `.github/workflows/todo-registrar-statistic.yaml`:

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

With no `config` input, the action scans the whole repository (`/code`).

## Documentation

1. [How it works](docs/how-it-works.md) — workflow steps, comment format, limitations.
2. [Inputs](docs/inputs.md) — input reference.
3. [Permissions](docs/permissions.md) — required workflow permissions.
4. [Examples](docs/examples.md) — workflow YAML for common setups.
5. [GitHub App](docs/github-app.md) — install the app so comments appear as `todo-registrar[bot]`.
6. [Posting service](service/README.md) — maintainer deployment guide.

## External documentation

- [TODO Registrar](https://github.com/Aeliot-Tm/todo-registrar) — scanner and configuration format.
