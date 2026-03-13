// Main Monitor Application

import { initErrorBoundary } from './lib/error-boundary.js';
import { initConnectionStatus } from './components/connection-status.js';
import { initLogViewer } from './components/log-viewer.js';
import { initHeartbeat } from './components/heartbeat.js';
import { initTimeline } from './components/timeline.js';
import { initCrossRepoBoard } from './components/cross-repo-board.js';
import { initStudioPulse } from './components/studio-pulse.js';
import { initAgentActivity } from './components/agent-activity.js';

// Store cleanup functions
const cleanupFunctions = [];

// Error handling for refresh functions
function wrapRefreshFunction(refreshFn, name) {
  return async function wrappedRefresh() {
    try {
      return await refreshFn();
    } catch (error) {
      console.error(`Error in ${name} refresh:`, error);
      throw error;
    }
  };
}

export async function initMonitor() {
  try {
    // Initialize error boundary
    const errorBoundary = initErrorBoundary();
    console.log('Error boundary initialized');
    
    // Initialize components
    const connectionStatus = initConnectionStatus('#connection-status');
    if (connectionStatus) cleanupFunctions.push(connectionStatus.cleanup);
    
    const heartbeat = initHeartbeat('#heartbeat');
    if (heartbeat) cleanupFunctions.push(heartbeat.cleanup);
    
    const timeline = initTimeline('#timeline');
    if (timeline) cleanupFunctions.push(timeline.cleanup);
    
    const logViewer = initLogViewer('#log-viewer', '/api/logs');
    if (logViewer) cleanupFunctions.push(logViewer.cleanup);
    
    const crossRepoBoard = initCrossRepoBoard('#cross-repo-board');
    if (crossRepoBoard) cleanupFunctions.push(crossRepoBoard.cleanup);
    
    const studioPulse = initStudioPulse('#studio-pulse');
    if (studioPulse) cleanupFunctions.push(studioPulse.cleanup);
    
    const agentActivity = initAgentActivity('#agent-activity');
    if (agentActivity) cleanupFunctions.push(agentActivity.cleanup);
    
    // Setup retry functions - wrap them for error handling
    window.__retryHeartbeat = wrapRefreshFunction(async () => {
      const hb = document.querySelector('.heartbeat');
      if (hb && hb._refresh) return hb._refresh();
    }, 'Heartbeat');
    
    window.__retryTimeline = wrapRefreshFunction(async () => {
      const tl = document.querySelector('.timeline');
      if (tl && tl._refresh) return tl._refresh();
    }, 'Timeline');
    
    window.__retryCrossRepoBoard = wrapRefreshFunction(async () => {
      const crb = document.querySelector('.cross-repo-board');
      if (crb && crb._refresh) return crb._refresh();
    }, 'CrossRepoBoard');
    
    window.__retryAgentActivity = wrapRefreshFunction(async () => {
      const aa = document.querySelector('.agent-activity');
      if (aa && aa._refresh) return aa._refresh();
    }, 'AgentActivity');
    
    console.log('Monitor initialized successfully');
    
    return {
      cleanup: () => {
        cleanupFunctions.forEach(fn => {
          try {
            fn();
          } catch (error) {
            console.error('Error during cleanup:', error);
          }
        });
      }
    };
  } catch (error) {
    console.error('Failed to initialize monitor:', error);
    throw error;
  }
}

// Initialize when DOM is ready
if (typeof window !== 'undefined') {
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initMonitor);
  } else {
    initMonitor();
  }
}

export default initMonitor;
