import { createRemoteJWKSet, jwtVerify } from 'jose';

const JWKS = createRemoteJWKSet(
  new URL('https://token.actions.githubusercontent.com/.well-known/jwks'),
);

const DEFAULT_AUDIENCE = 'todo-registrar-statistic-action';

export function expectedAudience(env) {
  return env.OIDC_AUDIENCE || DEFAULT_AUDIENCE;
}

export async function verifyWorkflowOidcToken(token, repository, env) {
  if (!token) {
    throw new Error('oidc_token is required');
  }

  const audience = expectedAudience(env);
  const { payload } = await jwtVerify(token, JWKS, {
    issuer: 'https://token.actions.githubusercontent.com',
    audience,
  });

  if (payload.repository !== repository) {
    throw new Error(
      `OIDC repository mismatch: token is for ${payload.repository ?? 'unknown'}, request is for ${repository}`,
    );
  }

  if (typeof payload.repository !== 'string') {
    throw new Error('OIDC token is missing repository claim');
  }

  return payload;
}
