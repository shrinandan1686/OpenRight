// Cloudflare Workers entry point for OpenRight URL shortener

/**
 * Main worker handler
 * Handles incoming requests and routes them accordingly
 */
export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const path = url.pathname;

    // Enable CORS for mobile app
    const corsHeaders = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    };

    // Handle preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders });
    }

    try {
      // API: Shorten URL
      if (path === '/api/shorten' && request.method === 'POST') {
        const response = await handleShorten(request, env, corsHeaders);
        // Track successful link creation
        if (response.status === 200) {
          trackMetric(env, 'links_created');
        }
        return response;
      }

      // API: Analytics (silent tracking)
      if (path === '/api/analytics' && request.method === 'POST') {
        return await handleAnalytics(request, env, corsHeaders);
      }

      // Redirect: Short code lookup
      if (path.length > 1 && !path.startsWith('/api')) {
        return await handleRedirect(request, env, path);
      }

      // Default response
      return new Response('OpenRight URL Shortener', {
        headers: { ...corsHeaders, 'Content-Type': 'text/plain' },
      });
    } catch (error) {
      console.error('Worker error:', error);
      trackMetric(env, 'errors');
      return new Response(
        JSON.stringify({ error: error.message || 'Internal server error' }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }
  },
};

/**
 * Handle URL shortening
 */
async function handleShorten(request, env, corsHeaders) {
  try {
    // Rate limiting: 10 requests per minute per IP
    const clientIp = request.headers.get('CF-Connecting-IP') || 'unknown';
    const rateLimitKey = `ratelimit:${clientIp}`;
    const rateLimitWindow = 60; // seconds
    const rateLimitMax = 10; // requests

    // Check rate limit
    const currentCount = await env.LINKS.get(rateLimitKey);
    const requestCount = currentCount ? parseInt(currentCount) : 0;

    if (requestCount >= rateLimitMax) {
      return new Response(
        JSON.stringify({
          error: 'Rate limit exceeded. Please try again in a minute.'
        }),
        {
          status: 429,
          headers: {
            ...corsHeaders,
            'Content-Type': 'application/json',
            'Retry-After': '60',
          },
        }
      );
    }

    // Increment rate limit counter
    await env.LINKS.put(
      rateLimitKey,
      (requestCount + 1).toString(),
      { expirationTtl: rateLimitWindow }
    );

    const body = await request.json();
    const { url } = body;

    // Validate input
    if (!url || typeof url !== 'string') {
      return new Response(
        JSON.stringify({ error: 'URL is required' }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // Validate YouTube URL
    if (!isYouTubeUrl(url)) {
      return new Response(
        JSON.stringify({ error: 'Invalid YouTube URL' }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // Generate short code (6 characters)
    const shortCode = generateShortCode();

    // Store in KV (Cloudflare Workers KV)
    // Format: { originalUrl, createdAt, clicks }
    const linkData = {
      originalUrl: url,
      videoId: extractYouTubeId(url),
      createdAt: new Date().toISOString(),
      clicks: 0,
    };

    await env.LINKS.put(shortCode, JSON.stringify(linkData));

    // Return shortened URL
    const shortUrl = `${new URL(request.url).origin}/${shortCode}`;

    return new Response(
      JSON.stringify({ shortUrl, shortCode }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  } catch (error) {
    console.error('Shorten error:', error);
    return new Response(
      JSON.stringify({ error: 'Failed to shorten URL' }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  }
}

/**
 * Handle redirect from short code
 */
async function handleRedirect(request, env, path) {
  const shortCode = path.substring(1); // Remove leading slash

  // Lookup in KV
  const linkDataStr = await env.LINKS.get(shortCode);

  if (!linkDataStr) {
    return new Response('Link not found', { status: 404 });
  }

  const linkData = JSON.parse(linkDataStr);

  // Increment click counter (fire and forget)
  incrementClicks(env, shortCode, linkData);

  // Serve redirect HTML page
  const html = generateRedirectPage(linkData.videoId, linkData.originalUrl);

  return new Response(html, {
    status: 200,
    headers: { 'Content-Type': 'text/html' },
  });
}

/**
 * Handle analytics tracking
 */
async function handleAnalytics(request, env, corsHeaders) {
  try {
    const body = await request.json();
    // For MVP, we just acknowledge receipt
    // In production, you'd store this in KV or send to analytics service

    return new Response(
      JSON.stringify({ success: true }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  } catch (error) {
    // Silent fail for analytics
    return new Response(
      JSON.stringify({ success: false }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  }
}

/**
 * Increment click counter (async, fire and forget)
 */
async function incrementClicks(env, shortCode, linkData) {
  try {
    linkData.clicks = (linkData.clicks || 0) + 1;
    linkData.lastClickedAt = new Date().toISOString();
    await env.LINKS.put(shortCode, JSON.stringify(linkData));
  } catch (error) {
    console.error('Failed to increment clicks:', error);
  }
}

/**
 * Generate random short code (6 characters)
 */
function generateShortCode() {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  let code = '';
  for (let i = 0; i < 6; i++) {
    code += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return code;
}

/**
 * Track metrics (simple counter in KV)
 */
async function trackMetric(env, metricName) {
  try {
    const today = new Date().toISOString().split('T')[0]; // YYYY-MM-DD
    const key = `metrics:${metricName}:${today}`;

    const current = await env.LINKS.get(key);
    const count = current ? parseInt(current) : 0;

    await env.LINKS.put(key, (count + 1).toString(), {
      expirationTtl: 86400 * 30, // Keep for 30 days
    });
  } catch (error) {
    console.error('Metrics tracking error:', error);
    // Don't fail the request if metrics fail
  }
}

/**
 * Validate YouTube URL
 */
function isYouTubeUrl(url) {
  const youtubeRegex = /^(https?:\/\/)?(www\.|m\.)?(youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]{11})/;
  return youtubeRegex.test(url);
}

/**
 * Extract YouTube video ID
 */
function extractYouTubeId(url) {
  const shortMatch = url.match(/youtu\.be\/([a-zA-Z0-9_-]{11})/);
  if (shortMatch) return shortMatch[1];

  const longMatch = url.match(/[?&]v=([a-zA-Z0-9_-]{11})/);
  if (longMatch) return longMatch[1];

  return null;
}

/**
 * Generate redirect HTML page with deep linking logic
 */
function generateRedirectPage(videoId, originalUrl) {
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Opening YouTube...</title>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: #FFFFFF;
      display: flex;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
      padding: 24px;
    }
    .container {
      text-align: center;
      max-width: 400px;
    }
    .icon {
      width: 64px;
      height: 64px;
      margin: 0 auto 24px;
      background: #0066FF;
      border-radius: 32px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 32px;
    }
    h1 {
      font-size: 24px;
      font-weight: 600;
      color: #1C1E21;
      margin-bottom: 12px;
    }
    p {
      font-size: 16px;
      color: #65676B;
      margin-bottom: 32px;
      line-height: 1.5;
    }
    .btn {
      display: inline-block;
      width: 100%;
      padding: 16px 24px;
      font-size: 16px;
      font-weight: 600;
      text-decoration: none;
      border-radius: 12px;
      transition: all 0.2s;
      cursor: pointer;
      border: none;
      font-family: inherit;
    }
    .btn-primary {
      background: #0066FF;
      color: #FFFFFF;
      margin-bottom: 12px;
    }
    .btn-primary:hover {
      background: #0052CC;
    }
    .btn-secondary {
      background: #F8F9FA;
      color: #1C1E21;
      border: 1px solid #E4E6EB;
    }
    .btn-secondary:hover {
      background: #F0F2F5;
    }
    .loader {
      display: inline-block;
      width: 20px;
      height: 20px;
      border: 3px solid #E4E6EB;
      border-top-color: #0066FF;
      border-radius: 50%;
      animation: spin 0.8s linear infinite;
    }
    @keyframes spin {
      to { transform: rotate(360deg); }
    }
    .loading-text {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 12px;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="icon">▶</div>
    <h1 id="title">Opening YouTube...</h1>
    <p id="description">
      <span class="loading-text">
        <span class="loader"></span>
        <span>Launching the YouTube app</span>
      </span>
    </p>
    
    <button id="openBtn" class="btn btn-primary" style="display: none;" onclick="openApp()">
      Open in YouTube App
    </button>
    
    <a id="webBtn" href="${originalUrl}" class="btn btn-secondary" style="display: none;">
      Continue in Browser
    </a>
  </div>

  <script>
    const videoId = '${videoId}';
    const webUrl = '${originalUrl}';
    let redirected = false;

    // Detect platform
    const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent);
    const isAndroid = /Android/.test(navigator.userAgent);

    // Generate deep link
    let deepLink;
    if (isIOS) {
      deepLink = \`vnd.youtube://watch?v=\${videoId}\`;
    } else if (isAndroid) {
      deepLink = \`vnd.youtube://\${videoId}\`;
    } else {
      // Desktop - just redirect to web
      window.location.href = webUrl;
    }

    // Try automatic redirect
    function tryAutoRedirect() {
      if (deepLink && !redirected) {
        redirected = true;
        window.location.href = deepLink;
        
        // Fallback: If app doesn't open in 1.5s, show buttons
        setTimeout(() => {
          document.getElementById('title').textContent = 'Ready to Watch?';
          document.getElementById('description').innerHTML = 'Tap below to open in the YouTube app';
          document.getElementById('openBtn').style.display = 'inline-block';
          document.getElementById('webBtn').style.display = 'inline-block';
        }, 1500);
      }
    }

    // Open app manually
    function openApp() {
      if (deepLink) {
        window.location.href = deepLink;
        // Fallback to web after 2s
        setTimeout(() => {
          window.location.href = webUrl;
        }, 2000);
      }
    }

    // Auto-redirect on load
    window.addEventListener('load', () => {
      setTimeout(tryAutoRedirect, 300);
    });
  </script>
</body>
</html>`;
}
