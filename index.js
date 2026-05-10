export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    
    // Dashboard URL - redirect to the clean path
    if (url.pathname === '/' || url.pathname === '/dashboard') {
      return fetch('https://c5ecd76a.openclaw-dashboard-7vh.pages.dev/');
    }
    
    // Proxy all other requests to the dashboard
    const dashboardUrl = 'https://c5ecd76a.openclaw-dashboard-7vh.pages.dev' + url.pathname + url.search;
    return fetch(dashboardUrl, request);
  }
};