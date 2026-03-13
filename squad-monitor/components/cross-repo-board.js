// Cross-Repo Board Component with error state and retry

import { apiGet } from '../lib/api.js';

export function CrossRepoBoard() {
  const container = document.createElement('div');
  container.className = 'cross-repo-board';
  
  const content = document.createElement('div');
  content.className = 'board-content';
  
  let refreshInterval = null;
  let isClosed = false;
  
  function renderError(error) {
    const errorEl = document.createElement('div');
    errorEl.className = 'error-state';
    errorEl.innerHTML = `
      <div class="error-icon">📋</div>
      <div class="error-message">Could not load cross-repo board</div>
      <button class="retry-button">Retry</button>
    `;
    
    errorEl.querySelector('.retry-button').addEventListener('click', () => {
      refresh();
    });
    
    content.innerHTML = '';
    content.appendChild(errorEl);
    
    // Store retry function globally
    window.__retryCrossRepoBoard = refresh;
  }
  
  function renderBoard(data) {
    if (data?.error) {
      renderError(data.error);
      return;
    }
    
    content.innerHTML = '<div class="board-header">Repositories</div>';
    
    if (!data?.repositories || data.repositories.length === 0) {
      content.innerHTML += '<div class="board-empty">No repositories found</div>';
      return;
    }
    
    const boardList = document.createElement('div');
    boardList.className = 'board-list';
    
    data.repositories.forEach((repo) => {
      const repoEl = document.createElement('div');
      repoEl.className = 'board-item';
      
      repoEl.innerHTML = `
        <div class="repo-header">
          <div class="repo-name">${repo.name}</div>
          <div class="repo-status ${repo.status || 'unknown'}">${repo.status || 'unknown'}</div>
        </div>
        <div class="repo-details">
          ${repo.description ? `<div class="repo-desc">${repo.description}</div>` : ''}
          <div class="repo-stats">
            Issues: ${repo.issues || 0} | PRs: ${repo.pullRequests || 0}
          </div>
        </div>
      `;
      
      boardList.appendChild(repoEl);
    });
    
    content.appendChild(boardList);
  }
  
  async function refresh() {
    if (isClosed) return;
    
    try {
      const data = await apiGet('/api/cross-repo-board');
      renderBoard(data);
    } catch (error) {
      console.error('Cross-repo board error:', error);
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
  refreshInterval = setInterval(refresh, 10000); // Refresh every 10s
  
  return container;
}

export function initCrossRepoBoard(mountSelector) {
  const mount = document.querySelector(mountSelector);
  if (!mount) {
    console.warn(`Cross-repo board mount point not found: ${mountSelector}`);
    return null;
  }
  
  const component = CrossRepoBoard();
  mount.appendChild(component);
  
  return {
    element: component,
    cleanup: () => component.cleanup()
  };
}
