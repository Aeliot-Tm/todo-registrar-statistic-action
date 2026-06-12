import { createRepositoryInstallationToken } from './github-app.js';
import { verifyWorkflowOidcToken } from './oidc.js';
import { upsertPullRequestComment } from './upsert-comment.js';

function jsonResponse(status, body) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
    },
  });
}

function parseRepository(repository) {
  const match = /^([^/]+)\/([^/]+)$/.exec(repository ?? '');
  if (!match) {
    throw new Error('repository must be in owner/name format');
  }

  return { owner: match[1], repo: match[2] };
}

function assertEnv(env) {
  if (!env.TODO_REGISTRAR_APP_ID) {
    throw new Error('TODO_REGISTRAR_APP_ID is not configured on the posting service');
  }

  if (!env.TODO_REGISTRAR_APP_PRIVATE_KEY) {
    throw new Error('TODO_REGISTRAR_APP_PRIVATE_KEY is not configured on the posting service');
  }
}

export async function handleRequest(request, env) {
  const url = new URL(request.url);

  if (request.method === 'GET' && (url.pathname === '/' || url.pathname === '/health')) {
    return jsonResponse(200, { status: 'ok', service: 'todo-registrar-posting-service' });
  }

  if (request.method !== 'POST' || url.pathname !== '/v1/post-comment') {
    return jsonResponse(404, { error: 'not_found' });
  }

  let payload;
  try {
    payload = await request.json();
  } catch {
    return jsonResponse(400, { error: 'invalid_json' });
  }

  try {
    assertEnv(env);

    const repository = payload.repository;
    const prNumber = Number(payload.pr_number);
    const commentBody = payload.comment_body;
    const oidcToken = payload.oidc_token;

    if (!repository || !Number.isInteger(prNumber) || prNumber < 1) {
      throw new Error('repository and pr_number are required');
    }

    if (typeof commentBody !== 'string' || commentBody.length === 0) {
      throw new Error('comment_body is required');
    }

    await verifyWorkflowOidcToken(oidcToken, repository, env);

    const { owner, repo } = parseRepository(repository);
    const installationToken = await createRepositoryInstallationToken(owner, repo, env);
    const result = await upsertPullRequestComment({
      owner,
      repo,
      prNumber,
      commentBody,
      installationToken,
      env,
    });

    return jsonResponse(200, result);
  } catch (error) {
    const message = error instanceof Error ? error.message : 'unknown_error';
    const status = message.includes('OIDC') || message.includes('oidc_token') ? 401 : 400;
    return jsonResponse(status, { error: message });
  }
}
