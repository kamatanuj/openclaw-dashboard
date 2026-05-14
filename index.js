export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    
    // Use the latest deployed version
    const PAGES_URL = 'https://88f13ab7.openclaw-dashboard-7vh.pages.dev';
    
    // For all requests, fetch from Pages with cache-busting
    const dashboardUrl = PAGES_URL + url.pathname + url.search;
    
    return fetch(dashboardUrl, {
      cf: {
        // Always fetch fresh from origin
        cacheTtl: 0,
        cacheEverything: false,
      },
      headers: {
        ...request.headers,
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0',
      }
    });
  }
};