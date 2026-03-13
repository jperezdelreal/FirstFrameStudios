// Timeline Component with error state and retry

import { apiGet } from '../lib/api.js';

export function Timeline() {
  const container = document.createElement('div');
  container.className = 'timeline';
  
  const content = document.createElement('div');
  content.className = 'timeline-content';
  
  let refreshInterval = null;
  let isClosed = false;
  
  function renderError(error) {
    const errorEl = document.createElement('div');
    errorEl.className = 'error-state';
    errorEl.innerHTML = `
      <div class="error-icon">⏰</div>
      <div class="error-message">Could not load timeline</div>
      <button class="retry-button">Retry</button>
    `;
    
    errorEl.querySelector('.retry-button').addEventListener('click', () => {
      refresh();
    });
    
    content.innerHTML = '';
    content.appendChild(errorEl);
    
    // Store retry function globally
    window.__retryTimeline = refresh;
  }
  
  function renderTimeline(data) {
    if (data?.error) {
      renderError(data.error);
      return;
    }
    
    content.innerHTML = '<div class="timeline-header">Activity Timeline</div>';
    
    if (!data?.events || data.events.length === 0) {
      content.innerHTML += '<div class="timeline-empty">No events yet</div>';
      return;
    }
    
    const timelineList = document.createElement('div');
    timelineList.className = 'timeline-list';
    
    data.events.forEach((event, index) => {
      const eventEl = document.createElement('div');
      eventEl.className = 'timeline-event';
      
      const time = new Date(event.timestamp).toLocaleTimeString();
      eventEl.innerHTML = `
        <div class="timeline-dot"></div>
        <div class="timeline-event-content">
          <div class="timeline-event-time">${time}</div>
          <div class="timeline-event-title">${event.title}</div>
          ${event.description ? `<div class="timeline-event-desc">${event.description}</div>` : ''}
        </div>
      `;
      
      timelineList.appendChild(eventEl);
    });
    
    content.appendChild(timelineList);
  }
  
  async function refresh() {
    if (isClosed) return;
    
    try {
      const data = await apiGet('/api/timeline');
      renderTimeline(data);
    } catch (error) {
      console.error('Timeline error:', error);
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
  refreshInterval = setInterval(refresh, 5000); // Refresh every 5s
  
  return container;
}

export function initTimeline(mountSelector) {
  const mount = document.querySelector(mountSelector);
  if (!mount) {
    console.warn(`Timeline mount point not found: ${mountSelector}`);
    return null;
  }
  
  const component = Timeline();
  mount.appendChild(component);
  
  return {
    element: component,
    cleanup: () => component.cleanup()
  };
}
