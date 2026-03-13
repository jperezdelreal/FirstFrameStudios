// API utilities with connection state tracking and error handling

const API_TIMEOUT = 10000; // 10 seconds

export const ConnectionState = {
  OPERATIONAL: 'operational',
  DEGRADED: 'degraded',
  OFFLINE: 'offline'
};

let connectionState = ConnectionState.OPERATIONAL;
let connectionStateCallbacks = [];

export function getConnectionState() {
  return connectionState;
}

export function onConnectionStateChange(callback) {
  connectionStateCallbacks.push(callback);
  return () => {
    connectionStateCallbacks = connectionStateCallbacks.filter(cb => cb !== callback);
  };
}

function setConnectionState(state) {
  if (connectionState !== state) {
    connectionState = state;
    connectionStateCallbacks.forEach(cb => cb(state));
  }
}

function logError(context, error) {
  const timestamp = new Date().toISOString();
  console.error(`[${timestamp}] ${context}:`, error);
  
  // Could send to remote logging service here
  if (typeof window !== 'undefined' && window.__errorLog) {
    window.__errorLog({
      timestamp,
      context,
      error: error.message,
      stack: error.stack
    });
  }
}

async function fetchWithTimeout(url, options = {}) {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), API_TIMEOUT);
  
  try {
    const response = await fetch(url, {
      ...options,
      signal: controller.signal
    });
    
    clearTimeout(timeoutId);
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }
    
    setConnectionState(ConnectionState.OPERATIONAL);
    return response;
  } catch (error) {
    clearTimeout(timeoutId);
    
    if (error.name === 'AbortError') {
      logError(`fetch(${url})`, new Error('Request timeout'));
      setConnectionState(ConnectionState.DEGRADED);
    } else if (error instanceof TypeError || !navigator.onLine) {
      logError(`fetch(${url})`, error);
      setConnectionState(ConnectionState.OFFLINE);
    } else {
      logError(`fetch(${url})`, error);
      setConnectionState(ConnectionState.DEGRADED);
    }
    
    throw error;
  }
}

export async function apiGet(endpoint) {
  try {
    const response = await fetchWithTimeout(endpoint, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json'
      }
    });
    
    return await response.json();
  } catch (error) {
    logError(`GET ${endpoint}`, error);
    throw error;
  }
}

export async function apiPost(endpoint, data) {
  try {
    const response = await fetchWithTimeout(endpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(data)
    });
    
    return await response.json();
  } catch (error) {
    logError(`POST ${endpoint}`, error);
    throw error;
  }
}

export async function apiPut(endpoint, data) {
  try {
    const response = await fetchWithTimeout(endpoint, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(data)
    });
    
    return await response.json();
  } catch (error) {
    logError(`PUT ${endpoint}`, error);
    throw error;
  }
}

export async function apiDelete(endpoint) {
  try {
    const response = await fetchWithTimeout(endpoint, {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json'
      }
    });
    
    return await response.json();
  } catch (error) {
    logError(`DELETE ${endpoint}`, error);
    throw error;
  }
}

export function openSSE(endpoint, onMessage, onError) {
  try {
    const eventSource = new EventSource(endpoint);
    
    eventSource.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);
        setConnectionState(ConnectionState.OPERATIONAL);
        onMessage(data);
      } catch (error) {
        logError(`SSE message parse(${endpoint})`, error);
        if (onError) onError(error);
      }
    };
    
    eventSource.onerror = (error) => {
      logError(`SSE error(${endpoint})`, error);
      setConnectionState(ConnectionState.DEGRADED);
      if (onError) onError(error);
    };
    
    return eventSource;
  } catch (error) {
    logError(`SSE open(${endpoint})`, error);
    setConnectionState(ConnectionState.OFFLINE);
    if (onError) onError(error);
    throw error;
  }
}
