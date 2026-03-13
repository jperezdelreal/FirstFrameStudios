// Agent Activity Component with error state and retry

import { apiGet } from '../lib/api.js';

export function AgentActivity() {
  const container = document.createElement('div');
  container.className = 'agent-activity';
  
  const content = document.createElement('div');
  content.className = 'activity-content';
  
  let refreshInterval = null;
  let isClosed = false;
  
  function renderError(error) {
    const errorEl = document.createElement('div');
    errorEl.className = 'error-state';
    errorEl.innerHTML = `
      <div class="error-icon">🤖</div>
      <div class="error-message">Could not load agent activity</div>
      <button class="retry-button">Retry</button>
    `;
    
    errorEl.querySelector('.retry-button').addEventListener('click', () => {
      refresh();
    });
    
    content.innerHTML = '';
    content.appendChild(errorEl);
    
    // Store retry function globally
    window.__retryAgentActivity = refresh;
  }
  
  function renderActivity(data) {
    if (data?.error) {
      renderError(data.error);
      return;
    }
    
    content.innerHTML = '<div class="activity-header">Agent Activity</div>';
    
    if (!data?.agents || data.agents.length === 0) {
      content.innerHTML += '<div class="activity-empty">No agent activity</div>';
      return;
    }
    
    const activityList = document.createElement('div');
    activityList.className = 'activity-list';
    
    data.agents.forEach((agent) => {
      const agentEl = document.createElement('div');
      agentEl.className = `agent-item agent-status-${agent.status || 'idle'}`;
      
      const lastActivity = agent.lastActivityTime ? 
        new Date(agent.lastActivityTime).toLocaleTimeString() : 
        'Never';
      
      agentEl.innerHTML = `
        <div class="agent-header">
          <div class="agent-name">${agent.name}</div>
          <div class="agent-status-badge ${agent.status || 'idle'}">${agent.status || 'idle'}</div>
        </div>
        <div class="agent-details">
          <div class="agent-task">${agent.currentTask || 'Idle'}</div>
          <div class="agent-activity-time">Last: ${lastActivity}</div>
          ${agent.progress !== undefined ? `<div class="agent-progress">${agent.progress}%</div>` : ''}
        </div>
      `;
      
      activityList.appendChild(agentEl);
    });
    
    content.appendChild(activityList);
  }
  
  async function refresh() {
    if (isClosed) return;
    
    try {
      const data = await apiGet('/api/agent-activity');
      renderActivity(data);
    } catch (error) {
      console.error('Agent activity error:', error);
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
  refreshInterval = setInterval(refresh, 3000); // Refresh every 3s
  
  return container;
}

export function initAgentActivity(mountSelector) {
  const mount = document.querySelector(mountSelector);
  if (!mount) {
    console.warn(`Agent activity mount point not found: ${mountSelector}`);
    return null;
  }
  
  const component = AgentActivity();
  mount.appendChild(component);
  
  return {
    element: component,
    cleanup: () => component.cleanup()
  };
}
