export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    
    // Use the latest deployed version
    const PAGES_URL = 'https://407d98f0.openclaw-dashboard-7vh.pages.dev';
    
    // Dashboard URL - redirect to the clean path
    if (url.pathname === '/' || url.pathname === '/dashboard') {
      return fetch(PAGES_URL + '/', {
        headers: {
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache'
        }
      });
    }
    
    // Proxy all other requests to the dashboard with no-cache headers
    const dashboardUrl = PAGES_URL + url.pathname + url.search;
    return fetch(dashboardUrl, {
      headers: {
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache'
      }
    });
  }
};