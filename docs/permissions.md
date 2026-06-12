# Permissions

## Workflow permissions

```yaml
permissions:
  contents: read
  pull-requests: write
```

| Permission | Why |
|------------|-----|
| `contents: read` | Checkout the repository for scanning |
| `pull-requests: write` | Create and update PR comments |

`issues: write` and `contents: write` are **not** required — the action does not create tracker issues or commit changes.

## TODO Registrar GitHub App

Install the [TODO Registrar GitHub App](https://github.com/apps/todo-registrar) on each repository where comments should be posted. Use the [reusable workflow](examples.md#post-comments-as-the-todo-registrar-bot); consumer repositories do not need workflow secrets.

## Repository settings

No special repository settings are required beyond standard Actions permissions.

## Fork pull requests

When `pull_request.head.repo.fork` is `true`, the action skips posting a comment and completes successfully with a
workflow notice. The default `GITHUB_TOKEN` from a fork workflow cannot comment on the upstream pull request.

## Related documentation

- [Examples](examples.md)
- [How it works](how-it-works.md)
