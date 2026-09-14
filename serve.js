const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 5050;
const WEB_DIR = path.join(__dirname, 'build', 'web');

const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.wasm': 'application/wasm',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2'
};

const server = http.createServer((req, res) => {
  // Handle CORS OPTIONS preflight
  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': '*'
    });
    res.end();
    return;
  }

  // Reverse proxy for backend images to solve Flutter Web CORS restrictions
  if (req.url.startsWith('/images/')) {
    const fallbackImage = (url) => {
      let assetName = 'car1.png';
      if (url.includes('slider') || url.includes('banner')) assetName = 'featurecar1.png';
      else if (url.includes('type')) assetName = 'jeep.png';
      else if (url.includes('brand')) assetName = 'audiCar.png';
      else if (url.includes('profile')) assetName = 'profile.png';
      const fallbackPath = path.join(WEB_DIR, 'assets', 'assets', assetName);
      if (fs.existsSync(fallbackPath)) {
        res.writeHead(200, {
          'Content-Type': 'image/png',
          'Access-Control-Allow-Origin': '*',
          'Cache-Control': 'public, max-age=86400'
        });
        fs.createReadStream(fallbackPath).pipe(res);
      } else {
        res.writeHead(404);
        res.end();
      }
    };

    const targetUrl = 'https://carlink.cscodetech.cloud' + req.url;
    const https = require('https');
    const proxyReq = https.get(targetUrl, (proxyRes) => {
      if (proxyRes.statusCode >= 400) {
        fallbackImage(req.url);
        return;
      }
      res.writeHead(proxyRes.statusCode, {
        'Content-Type': proxyRes.headers['content-type'] || 'image/png',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, OPTIONS',
        'Cache-Control': 'public, max-age=86400'
      });
      proxyRes.pipe(res);
    });
    proxyReq.on('error', () => fallbackImage(req.url));
    return;
  }

  let reqPath = req.url.split('?')[0];
  if (reqPath === '/') reqPath = '/index.html';

  let filePath = path.join(WEB_DIR, reqPath);

  fs.stat(filePath, (err, stats) => {
    if (err || !stats.isFile()) {
      // SPA fallback
      filePath = path.join(WEB_DIR, 'index.html');
    }

    const ext = path.extname(filePath).toLowerCase();
    const contentType = MIME_TYPES[ext] || 'application/octet-stream';

    fs.readFile(filePath, (readErr, content) => {
      if (readErr) {
        res.writeHead(500);
        res.end('Server Error');
        return;
      }
      res.writeHead(200, {
        'Content-Type': contentType,
        'Access-Control-Allow-Origin': '*'
      });
      res.end(content);
    });
  });
});

server.listen(PORT, () => {
  console.log(`CarLink Web Server running at http://localhost:${PORT}`);
});
