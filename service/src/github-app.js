import { createPrivateKey } from 'node:crypto';
import { SignJWT } from 'jose';

const DEFAULT_API_URL = 'https://api.github.com';

function apiUrl(env) {
  return (env.GITHUB_API_URL || DEFAULT_API_URL).replace(/\/$/, '');
}

export async function createAppJwt(appId, privateKeyPem) {
  const privateKey = createPrivateKey(privateKeyPem);
  const now = Math.floor(Date.now() / 1000);

  return new SignJWT({})
    .setProtectedHeader({ alg: 'RS256' })
    .setIssuedAt(now - 60)
    .setExpirationTime(now + 600)
    .setIssuer(String(appId))
    .sign(privateKey);
}

async function githubAppRequest(path, { env, method = 'GET', body }) {
  const jwt = await createAppJwt(env.TODO_REGISTRAR_APP_ID, env.TODO_REGISTRAR_APP_PRIVATE_KEY);
  const response = await fetch(`${apiUrl(env)}${path}`, {
    method,
    headers: {
      Accept: 'application/vnd.github+json',
      Authorization: `Bearer ${jwt}`,
      'User-Agent': 'todo-registrar-posting-service',
      ...(body ? { 'Content-Type': 'application/json' } : {}),
    },
    body: body ? JSON.stringify(body) : undefined,
  });

  if (!response.ok) {
    const text = await response.text();

    if (response.status === 404 && path.includes('/installation')) {
      throw new Error(
        'GitHub App is not installed on the target repository. Install it from https://github.com/apps/todo-registrar',
      );
    }

    throw new Error(`GitHub App API ${method} ${path} failed (${response.status}): ${text}`);
  }

  if (response.status === 204) {
    return null;
  }

  return response.json();
}

export async function getRepositoryInstallation(owner, repo, env) {
  return githubAppRequest(`/repos/${owner}/${repo}/installation`, { env });
}

export async function createInstallationToken(installationId, env) {
  const data = await githubAppRequest(`/app/installations/${installationId}/access_tokens`, {
    env,
    method: 'POST',
  });
  return data.token;
}

export async function createRepositoryInstallationToken(owner, repo, env) {
  const installation = await getRepositoryInstallation(owner, repo, env);
  return createInstallationToken(installation.id, env);
}
