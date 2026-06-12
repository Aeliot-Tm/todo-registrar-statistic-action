# Permissions

## Workflow permissions

```yaml
permissions:
  contents: read
  pull-requests: write
  id-token: write
```

| Permission | Why |
|------------|-----|
| `contents: read` | Checkout the repository for scanning |
| `pull-requests: write` | Required by GitHub for PR-related workflows (comment posting uses the GitHub App via the posting service) |
| `id-token: write` | Request an OIDC token so the posting service can verify the workflow run |

`issues: write` and `contents: write` are **not** required — the action does not create tracker issues or commit changes.

## TODO Registrar GitHub App

Install the [TODO Registrar GitHub App](https://github.com/apps/todo-registrar) on each repository where comments should be posted as `todo-registrar[bot]`.

Consumer repositories do **not** need workflow secrets for the App private key.

## Repository settings

No special repository settings are required beyond standard Actions permissions.

## Fork pull requests

When `pull_request.head.repo.fork` is `true`, the action skips posting a comment and completes successfully with a
workflow notice.

## Related documentation

- [Examples](examples.md)
- [How it works](how-it-works.md)
- [GitHub App](github-app.md)
