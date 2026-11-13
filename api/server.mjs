import { createServer } from 'node:http';
import { readFile } from 'node:fs/promises';

createServer(async (request, response) => {
  response.setHeader('Access-Control-Allow-Origin', '*');
  response.setHeader('Cache-Control', 'no-store');
  response.setHeader('Content-Type', 'application/json; charset=utf-8');

  if (request.method !== 'GET' || request.url !== '/products') {
    response.writeHead(404).end(JSON.stringify({ error: 'Not found' }));
    return;
  }

  try {
    response.end(await readFile(new URL('./products.json', import.meta.url)));
  } catch {
    response.writeHead(500).end(JSON.stringify({ error: 'Catalog unavailable' }));
  }
}).listen(8080, '0.0.0.0');
