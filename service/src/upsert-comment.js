const MARKER = 'TODO-REGISTRAR-STATISTIC:START';

function apiUrl(env) {
  return (env.GITHUB_API_URL || 'https://api.github.com').replace(/\/$/, '');
}

async function githubRequest(path, { env, token, method = 'GET', body }) {
  const response = await fetch(`${apiUrl(env)}${path}`, {
    method,
    headers: {
      Accept: 'application/vnd.github+json',
      Authorization: `Bearer ${token}`,
      'User-Agent': 'todo-registrar-posting-service',
      ...(body ? { 'Content-Type': 'application/json' } : {}),
    },
    body: body ? JSON.stringify(body) : undefined,
  });

  if (!response.ok) {
    const text = await response.text();
    throw new Error(`GitHub API ${method} ${path} failed (${response.status}): ${text}`);
  }

  if (response.status === 204) {
    return null;
  }

  return response.json();
}

async function listMatchingCommentIds(owner, repo, prNumber, token, env) {
  const matchingIds = [];
  let page = 1;

  while (true) {
    const comments = await githubRequest(
      `/repos/${owner}/${repo}/issues/${prNumber}/comments?per_page=100&page=${page}`,
      { env, token },
    );

    if (!Array.isArray(comments) || comments.length === 0) {
      break;
    }

    for (const comment of comments) {
      if (typeof comment.body === 'string' && comment.body.includes(MARKER)) {
        matchingIds.push(comment.id);
      }
    }

    if (comments.length < 100) {
      break;
    }

    page += 1;
  }

  return matchingIds;
}

export async function upsertPullRequestComment({
  owner,
  repo,
  prNumber,
  commentBody,
  installationToken,
  env,
}) {
  const matchingIds = await listMatchingCommentIds(
    owner,
    repo,
    prNumber,
    installationToken,
    env,
  );

  if (matchingIds.length > 1) {
    console.warn(
      `Found ${matchingIds.length} comments with marker ${MARKER}; updating the first match (id=${matchingIds[0]}).`,
    );
  }

  if (matchingIds.length > 0) {
    const commentId = matchingIds[0];
    await githubRequest(`/repos/${owner}/${repo}/issues/comments/${commentId}`, {
      env,
      token: installationToken,
      method: 'PATCH',
      body: { body: commentBody },
    });

    return { comment_id: commentId, comment_created: false };
  }

  const created = await githubRequest(`/repos/${owner}/${repo}/issues/${prNumber}/comments`, {
    env,
    token: installationToken,
    method: 'POST',
    body: { body: commentBody },
  });

  return { comment_id: created.id, comment_created: true };
}
