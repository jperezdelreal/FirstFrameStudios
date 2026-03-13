// Heartbeat Component with error state and retry

import { apiGet } from '../lib/api.js';

export function Heartbeat() {
  const container = document.createElement('div');
  container.className = 'heartbeat';
  
  const status = document.createElement('div');
  status.className = 'heartbeat-status';
  
  let refreshInterval = null;
  let isClosed = false;
  
  function renderError(error) {
    const errorEl = document.createElement('div');
    errorEl.className = 'error-state';
    errorEl.innerHTML = `
      <div class="error-icon">❌</div>
      <div class="error-message">Could not load heartbeat</div>
      <button class="retry-button">Retry</button>
    `;
    
    errorEl.querySelector('.retry-button').addEventListener('click', () => {
      refresh();
    });
    
    status.innerHTML = '';
    status.appendChild(errorEl);
    
    // Store retry function globally
    window.__retryHeartbeat = refresh;
  }
  
  function renderHeartbeat(data) {
    if (data?.error) {
      renderError(data.error);
      return;
    }
    
    status.innerHTML = `
      <div class="heartbeat-indicator">💓</div>
      <div class="heartbeat-info">
        <div class="heartbeat-label">System Heartbeat</div>
        <div class="heartbeat-details">
          ${data?.uptime ? `Uptime: ${data.uptime}` : 'Running'}
        </div>
      </div>
    `;
  }
  
  async function refresh() {
    if (isClosed) return;
    
    try {
      const data = await apiGet('/api/heartbeat');
      renderHeartbeat(data);
    } catch (error) {
      console.error('Heartbeat error:', error);
      renderError(error);
    }
  }
  
  container.appendChild(status);
  
  // Cleanup function
  container.cleanup = () => {
    isClosed = true;
    if (refreshInterval) {
      clearInterval(refreshInterval);
    }
  };
  
  // Initial refresh and set interval
  refresh();
  refreshInterval = setInterval(refresh, 30000); // Refresh every 30s
  
  return container;
}

export function initHeartbeat(mountSelector) {
  const mount = document.querySelector(mountSelector);
  if (!mount) {
    console.warn(`Heartbeat mount point not found: ${mountSelector}`);
    return null;
  }
  
  const component = Heartbeat();
  mount.appendChild(component);
  
  return {
    element: component,
    cleanup: () => component.cleanup()
  };
}
