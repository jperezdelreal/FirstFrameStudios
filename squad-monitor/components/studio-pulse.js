// Studio Pulse Component - handles errors gracefully

import { apiGet } from '../lib/api.js';

export function StudioPulse() {
  const container = document.createElement('div');
  container.className = 'studio-pulse';
  
  const content = document.createElement('div');
  content.className = 'pulse-content';
  
  let refreshInterval = null;
  let isClosed = false;
  
  function renderError(error) {
    const errorEl = document.createElement('div');
    errorEl.className = 'error-state error-graceful';
    errorEl.innerHTML = `
      <div class="error-icon">✨</div>
      <div class="error-message">Studio activity unavailable</div>
      <div class="error-details">Retrying automatically...</div>
    `;
    
    content.innerHTML = '';
    content.appendChild(errorEl);
  }
  
  function renderPulse(data) {
    if (data?.error) {
      renderError(data.error);
      return;
    }
    
    content.innerHTML = `
      <div class="pulse-header">Studio Pulse</div>
      <div class="pulse-stats">
        <div class="pulse-stat">
          <div class="pulse-stat-label">Active Agents</div>
          <div class="pulse-stat-value">${data?.activeAgents || 0}</div>
        </div>
        <div class="pulse-stat">
          <div class="pulse-stat-label">Operations</div>
          <div class="pulse-stat-value">${data?.operations || 0}</div>
        </div>
        <div class="pulse-stat">
          <div class="pulse-stat-label">Status</div>
          <div class="pulse-stat-value ${data?.status || 'idle'}">${data?.status || 'idle'}</div>
        </div>
      </div>
    `;
    
    if (data?.lastUpdated) {
      const lastUpdate = document.createElement('div');
      lastUpdate.className = 'pulse-updated';
      lastUpdate.textContent = `Last updated: ${new Date(data.lastUpdated).toLocaleTimeString()}`;
      content.appendChild(lastUpdate);
    }
  }
  
  async function refresh() {
    if (isClosed) return;
    
    try {
      const data = await apiGet('/api/studio-pulse');
      renderPulse(data);
    } catch (error) {
      console.warn('Studio pulse error (will retry):', error);
      renderError(error);
    }
  }
  
  container.appendChild(content);
  
  // Cleanup function
  container.cleanup = () => {
    isClosed = true;
    if (refreshInterval) {
      clearInterval(refreshInterval);
    }
  };
  
  // Initial refresh and set interval
  refresh();
  refreshInterval = setInterval(refresh, 15000); // Refresh every 15s
  
  return container;
}

export function initStudioPulse(mountSelector) {
  const mount = document.querySelector(mountSelector);
  if (!mount) {
    console.warn(`Studio pulse mount point not found: ${mountSelector}`);
    return null;
  }
  
  const component = StudioPulse();
  mount.appendChild(component);
  
  return {
    element: component,
    cleanup: () => component.cleanup()
  };
}
