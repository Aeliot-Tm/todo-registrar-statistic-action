# TODO Registrar GitHub App

PR comments are posted as **`todo-registrar[bot]`** when using the reusable workflow.

## Maintainer setup (once)

1. Create and publish the GitHub App on the `todo-registrar` account:
   - **Issues**: Read and write
   - **Pull requests**: Read and write
2. In `Aeliot-Tm/todo-registrar-statistic-action` → **Settings → Secrets and variables → Actions**, add **repository secrets** (not environment secrets):
   - `TODO_REGISTRAR_APP_ID`
   - `TODO_REGISTRAR_APP_PRIVATE_KEY`

The private key is stored only in GitHub Secrets. It is not committed to the repository and is not shipped with the action package.

## Consumer setup (per repository)

1. [Install the TODO Registrar GitHub App](https://github.com/apps/todo-registrar) on your repository.
2. Call the [reusable workflow](examples.md#post-comments-as-the-todo-registrar-bot).

No workflow secrets, no `secrets: inherit`, no token values in YAML.

## Composite action without the reusable workflow

`uses: Aeliot-Tm/todo-registrar-statistic-action@v1` posts with `GITHUB_TOKEN` as `github-actions[bot]`. Use the reusable workflow for the app identity.

## Related documentation

- [Examples](examples.md)
- [Permissions](permissions.md)
