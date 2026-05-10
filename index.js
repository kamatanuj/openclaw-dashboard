export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    
    // Use the latest deployed version
    const PAGES_URL = 'https://f3f82efb.openclaw-dashboard-7vh.pages.dev';
    
    // Dashboard URL - redirect to the clean path
    if (url.pathname === '/' || url.pathname === '/dashboard') {
      return fetch(PAGES_URL + '/');
    }
    
    // Proxy all other requests to the dashboard
    const dashboardUrl = PAGES_URL + url.pathname + url.search;
    return fetch(dashboardUrl, request);
  }
};