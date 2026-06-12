# TODO Registrar GitHub App

PR comments are posted as **`todo-registrar[bot]`** when `post_as_app` is enabled (default).

## How it works

1. The consumer workflow runs the composite action and requests an OIDC token (`id-token: write`).
2. The action sends the comment body and OIDC token to the **maintainer-hosted posting service**.
3. The service validates the OIDC token, checks that the GitHub App is installed on the target repository, mints an installation access token with the App private key, and upserts the PR comment.

The App private key never leaves maintainer infrastructure. Consumer repositories do not need workflow secrets.

## Consumer setup

1. [Install the TODO Registrar GitHub App](https://github.com/apps/todo-registrar) on your repository.
2. Add the composite action to a `pull_request` workflow:

```yaml
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

No `secrets: inherit`, no App credentials in consumer YAML.

## Maintainer setup (once)

1. Create the GitHub App on the `todo-registrar` account with **Issues** and **Pull requests** read/write permissions.
2. Add repository secrets to `Aeliot-Tm/todo-registrar-statistic-action`:
   - `TODO_REGISTRAR_APP_ID`
   - `TODO_REGISTRAR_APP_PRIVATE_KEY`
   - `CLOUDFLARE_API_TOKEN`
   - `CLOUDFLARE_ACCOUNT_ID`
3. Deploy the [posting service](../service/README.md) (Cloudflare Workers workflow or `wrangler deploy`).
4. Ensure `posting_service_url` in `action.yml` matches the deployed worker URL.

Use **Post comment (manual)** workflow to verify App credentials and installation access without OIDC.

## Fallback: `github-actions[bot]`

Set `post_as_app: false` to post with `GITHUB_TOKEN` instead. Useful for forks or when the posting service is unavailable.

## Related documentation

- [Posting service](../service/README.md)
- [Examples](examples.md)
- [Permissions](permissions.md)
