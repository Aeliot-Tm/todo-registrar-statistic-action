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
- Always succeeds; reports when no unregistered TODOs are found.

## Quick start

Create a workflow file at `.github/workflows/todo-registrar-statistic.yaml`:

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
      - uses: Aeliot-Tm/todo-registrar-statistic-action@0.1.0
```

With no `config` input, the action scans the whole repository (`/code`).

## Documentation

1. [How it works](docs/how-it-works.md) — workflow steps, comment format, limitations.
2. [Inputs](docs/inputs.md) — input reference.
3. [Permissions](docs/permissions.md) — required workflow permissions.
4. [Examples](docs/examples.md) — workflow YAML for common setups.

## External documentation

- [TODO Registrar](https://github.com/Aeliot-Tm/todo-registrar) — scanner and configuration format.
