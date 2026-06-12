# TODO Registrar posting service

Maintainer-hosted HTTP service that posts PR comments as **`todo-registrar[bot]`**.

Consumer workflows never receive the GitHub App private key. They send an OIDC token from GitHub Actions plus the comment body; this service validates the token, mints an installation access token, and upserts the PR comment.

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/health` | Liveness probe |
| `POST` | `/v1/post-comment` | Upsert a PR comment |

### `POST /v1/post-comment`

```json
{
  "repository": "owner/repo",
  "pr_number": 42,
  "comment_body": "<markdown>",
  "oidc_token": "<github actions oidc jwt>"
}
```

Response:

```json
{
  "comment_id": 123456789,
  "comment_created": true
}
```

## Environment variables

| Variable | Required | Description |
|----------|----------|-------------|
| `TODO_REGISTRAR_APP_ID` | Yes | GitHub App ID |
| `TODO_REGISTRAR_APP_PRIVATE_KEY` | Yes | PEM private key |
| `OIDC_AUDIENCE` | No | Expected OIDC audience (`todo-registrar-statistic-action`) |
| `GITHUB_API_URL` | No | Defaults to `https://api.github.com` |

## Local development

```bash
cd service
npm ci
export TODO_REGISTRAR_APP_ID=...
export TODO_REGISTRAR_APP_PRIVATE_KEY="$(cat app.private-key.pem)"
npm start
```

## Deploy to Cloudflare Workers

1. Add repository secrets to `Aeliot-Tm/todo-registrar-statistic-action`:
   - `TODO_REGISTRAR_APP_ID`
   - `TODO_REGISTRAR_APP_PRIVATE_KEY`
   - `CLOUDFLARE_API_TOKEN`
   - `CLOUDFLARE_ACCOUNT_ID`
2. Run the **Deploy posting service** workflow, or locally:

```bash
cd service
npx wrangler secret put TODO_REGISTRAR_APP_ID
npx wrangler secret put TODO_REGISTRAR_APP_PRIVATE_KEY
npx wrangler deploy
```

3. Set the worker URL in `action.yml` (`posting_service_url` default) or override it from consumer workflows.

The default URL is `https://todo-registrar-posting.aeliot-tm.workers.dev`. Rename the worker in `wrangler.toml` if you need a different hostname.
