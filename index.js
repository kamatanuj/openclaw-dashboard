export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    
    // Use the latest deployed version
    const PAGES_URL = 'https://11b9f1be.openclaw-dashboard-7vh.pages.dev';
    
    // For all requests, fetch from Pages with cache-busting
    const dashboardUrl = PAGES_URL + url.pathname + url.search;
    
    return fetch(dashboardUrl, {
      cf: {
        // Always fetch fresh from origin - NO CACHE
        cacheTtl: 0,
        cacheEverything: false,
      },
      headers: {
        ...request.headers,
        'Cache-Control': 'no-cache, no-store, must-revalidate, max-age=0',
        'Pragma': 'no-cache',
        'Expires': '0',
        'CDN-Cache-Control': 'no-store',
        'Cloudflare-CDN-Cache-Control': 'no-store',
      }
    });
  }
};