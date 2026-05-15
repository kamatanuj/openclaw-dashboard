export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    const PAGES_URL = 'https://32970d04.openclaw-dashboard-7vh.pages.dev';
    const dashboardUrl = PAGES_URL + url.pathname + url.search;
    
    try {
      const response = await fetch(dashboardUrl, {
        headers: {
          'Cache-Control': 'no-cache, no-store, must-revalidate, max-age=0',
          'Pragma': 'no-cache',
        }
      });
      return response;
    } catch (error) {
      return new Response('Error: ' + error.message, { status: 500 });
    }
  }
};
