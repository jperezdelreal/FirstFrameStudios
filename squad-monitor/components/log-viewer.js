// Log Viewer Component with SSE reconnection and exponential backoff

import { openSSE } from '../lib/api.js';

const RECONNECT_DELAYS = [1000, 2000, 4000, 8000, 30000]; // 1s, 2s, 4s, 8s, 30s
const MAX_RETRIES = 10;

export function LogViewer(endpoint = '/api/logs') {
  const container = document.createElement('div');
  container.className = 'log-viewer';
  
  const badge = document.createElement('div');
  badge.className = 'log-stream-badge reconnecting';
  badge.textContent = 'Connecting...';
  
  const logs = document.createElement('div');
  logs.className = 'logs-container';
  
  let eventSource = null;
  let retryCount = 0;
  let reconnectTimeout = null;
  let isClosed = false;
  
  function renderError(error) {
    const errorEl = document.createElement('div');
    errorEl.className = 'log-error';
    errorEl.innerHTML = `
      <div class="error-icon">⚠️</div>
      <div class="error-message">Could not load logs</div>
      <div class="error-details">${error?.message || 'Unknown error'}</div>
      <button class="retry-button">Retry</button>
    `;
    
    errorEl.querySelector('.retry-button').addEventListener('click', () => {
      logs.innerHTML = '';
      connect();
    });
    
    logs.innerHTML = '';
    logs.appendChild(errorEl);
  }
  
  function updateBadge(status) {
    badge.className = `log-stream-badge ${status}`;
    
    const statusTexts = {
      'connected': '● Connected',
      'reconnecting': '⟳ Reconnecting...',
      'error': '✕ Connection Error'
    };
    
    badge.textContent = statusTexts[status] || status;
  }
  
  function addLog(message) {
    const logEntry = document.createElement('div');
    logEntry.className = 'log-entry';
    
    const timestamp = new Date().toLocaleTimeString();
    logEntry.innerHTML = `<span class="timestamp">[${timestamp}]</span> ${message}`;
    
    logs.appendChild(logEntry);
    
    // Keep only last 100 logs
    while (logs.children.length > 100) {
      logs.removeChild(logs.firstChild);
    }
    
    // Auto-scroll to bottom
    logs.scrollTop = logs.scrollHeight;
  }
  
  function connect() {
    if (isClosed) return;
    
    try {
      updateBadge('reconnecting');
      
      eventSource = openSSE(
        endpoint,
        (data) => {
          retryCount = 0;
          updateBadge('connected');
          
          if (data.message) {
            addLog(data.message);
          }
        },
        (error) => {
          if (!isClosed && retryCount < MAX_RETRIES) {
            const delayIndex = Math.min(retryCount, RECONNECT_DELAYS.length - 1);
            const delay = RECONNECT_DELAYS[delayIndex];
            
            console.warn(`SSE reconnecting in ${delay}ms (attempt ${retryCount + 1}/${MAX_RETRIES})`);
            
            reconnectTimeout = setTimeout(() => {
              retryCount++;
              connect();
            }, delay);
          } else if (retryCount >= MAX_RETRIES) {
            renderError(error);
            updateBadge('error');
          }
        }
      );
    } catch (error) {
      renderError(error);
      updateBadge('error');
    }
  }
  
  container.appendChild(badge);
  container.appendChild(logs);
  
  // Cleanup function
  container.cleanup = () => {
    isClosed = true;
    if (eventSource) {
      eventSource.close();
    }
    if (reconnectTimeout) {
      clearTimeout(reconnectTimeout);
    }
  };
  
  // Auto-connect
  connect();
  
  return container;
}

export function initLogViewer(mountSelector, endpoint = '/api/logs') {
  const mount = document.querySelector(mountSelector);
  if (!mount) {
    console.warn(`Log viewer mount point not found: ${mountSelector}`);
    return null;
  }
  
  const component = LogViewer(endpoint);
  mount.appendChild(component);
  
  return {
    element: component,
    cleanup: () => component.cleanup()
  };
}
