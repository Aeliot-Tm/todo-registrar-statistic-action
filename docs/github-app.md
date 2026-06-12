# TODO Registrar GitHub App

Use this setup to post PR comments as the `todo-registrar` bot without storing credentials in consumer repositories.

## Consumer setup (per repository)

1. Install the app: [github.com/apps/todo-registrar](https://github.com/apps/todo-registrar) → **Install**.
2. Use the reusable workflow (see [Examples](examples.md#post-comments-as-the-todo-registrar-bot)).

No PAT, no repository secrets, no token in workflow YAML.

## Why not a PAT in workflows?

A personal access token from the `todo-registrar` account would have to be stored as a secret in every repository that uses the action. The reusable workflow keeps app credentials only in the action repository; consumer workflows only trigger the workflow and grant standard `pull-requests: write` permission to the job.

## Related documentation

- [Examples](examples.md)
- [Permissions](permissions.md)
