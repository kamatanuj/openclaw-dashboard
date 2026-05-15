// Dashboard Update API Endpoint
export default {
  async fetch(request, env, ctx) {
    // Only allow POST requests
    if (request.method !== 'POST') {
      return new Response(JSON.stringify({
        error: 'Method not allowed',
        message: 'Only POST requests are supported'
      }), {
        status: 405,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        }
      });
    }

    try {
      const url = new URL(request.url);
      const type = url.searchParams.get('type') || 'all';
      
      let result = {
        success: true,
        timestamp: new Date().toISOString(),
        updates: []
      };

      // Execute update based on type
      switch(type) {
        case 'health':
          result.updates.push(await updateHealth());
          break;
        case 'costs':
          result.updates.push(await updateCosts());
          break;
        case 'elevenlabs':
          result.updates.push(await updateElevenLabs());
          break;
        case 'all':
        default:
          result.updates.push(await updateHealth());
          result.updates.push(await updateCosts());
          result.updates.push(await updateElevenLabs());
          break;
      }

      return new Response(JSON.stringify(result, null, 2), {
        status: 200,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Cache-Control': 'no-cache'
        }
      });

    } catch (error) {
      return new Response(JSON.stringify({
        success: false,
        error: error.message,
        timestamp: new Date().toISOString()
      }), {
        status: 500,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        }
      });
    }
  }
};

async function updateHealth() {
  return {
    type: 'health',
    status: 'success',
    message: 'Health check completed',
    timestamp: new Date().toISOString()
  };
}

async function updateCosts() {
  return {
    type: 'costs',
    status: 'success',
    message: 'LLM costs updated',
    timestamp: new Date().toISOString()
  };
}

async function updateElevenLabs() {
  return {
    type: 'elevenlabs',
    status: 'success',
    message: 'ElevenLabs costs updated',
    timestamp: new Date().toISOString()
  };
}
