import { createServer } from 'node:http';
import { handleRequest } from './handler.js';

const port = Number(process.env.PORT || 8787);

function loadEnv() {
  return {
    TODO_REGISTRAR_APP_ID: process.env.TODO_REGISTRAR_APP_ID,
    TODO_REGISTRAR_APP_PRIVATE_KEY: process.env.TODO_REGISTRAR_APP_PRIVATE_KEY,
    OIDC_AUDIENCE: process.env.OIDC_AUDIENCE,
    GITHUB_API_URL: process.env.GITHUB_API_URL,
  };
}

function readBody(request) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    request.on('data', (chunk) => chunks.push(chunk));
    request.on('end', () => resolve(Buffer.concat(chunks)));
    request.on('error', reject);
  });
}

createServer(async (req, res) => {
  const body = req.method === 'GET' || req.method === 'HEAD' ? undefined : await readBody(req);
  const host = req.headers.host ?? `127.0.0.1:${port}`;
  const request = new Request(`http://${host}${req.url ?? '/'}`, {
    method: req.method,
    headers: req.headers,
    body,
  });

  const response = await handleRequest(request, loadEnv());
  res.writeHead(response.status, Object.fromEntries(response.headers.entries()));
  res.end(Buffer.from(await response.arrayBuffer()));
}).listen(port, () => {
  console.log(`todo-registrar posting service listening on http://127.0.0.1:${port}`);
});
