# TODO Registrar GitHub App

Post PR comments as `todo-registrar[bot]` without storing credentials in consumer repositories.

## Maintainer setup (once)

### 1. Create the GitHub App

Sign in as the `todo-registrar` account and create a GitHub App:

- **GitHub App name**: `TODO Registrar` (comments appear as `todo-registrar[bot]`)
- **Webhook**: inactive
- **Repository permissions**:
  - **Issues**: Read and write
  - **Pull requests**: Read and write
- **Where can this GitHub App be installed?**: Any account

Create a private key and note the **App ID**. Publish the app so other repositories can install it.

### 2. Store credentials in the action repository

Cross-repo reusable workflows **cannot** read regular repository secrets from the action repo. Use an **environment** instead:

1. Open `Aeliot-Tm/todo-registrar-statistic-action` → **Settings → Environments**.
2. Create environment `todo-registrar-bot` (name must match `.github/workflows/statistic.yaml`).
3. Add environment secrets:
   - `TODO_REGISTRAR_APP_ID` — the App ID
   - `TODO_REGISTRAR_APP_PRIVATE_KEY` — the PEM private key

Do **not** rely on repository-level secrets alone — they are empty when the workflow is called from another repository.

## Consumer setup (per repository)

1. Install the app: [github.com/apps/todo-registrar](https://github.com/apps/todo-registrar) → **Install**.
2. Call the reusable workflow (see [Examples](examples.md#post-comments-as-the-todo-registrar-bot)).

No PAT, no repository secrets, no token in workflow YAML.

## Related documentation

- [Examples](examples.md)
- [Permissions](permissions.md)
