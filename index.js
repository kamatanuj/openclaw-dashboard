export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    
    // Use the latest deployed version
    const PAGES_URL = 'https://70f64c21.openclaw-dashboard-7vh.pages.dev';
    
    // For all requests, fetch from Pages
    const dashboardUrl = PAGES_URL + url.pathname + url.search;
    
    try {
      // Fetch from Pages with no cache
      const response = await fetch(dashboardUrl, {
        headers: {
          'Cache-Control': 'no-cache, no-store, must-revalidate, max-age=0',
          'Pragma': 'no-cache',
        }
      });
      
      // Return the response directly
      return response;
    } catch (error) {
      return new Response('Error: ' + error.message, { status: 500 });
    }
  }
};
