// Connection Status Component
// Shows operational (green), degraded (yellow), or offline (red) status

import { getConnectionState, onConnectionStateChange, ConnectionState } from '../lib/api.js';

export function ConnectionStatus() {
  const container = document.createElement('div');
  container.className = 'connection-status';
  
  const indicator = document.createElement('div');
  indicator.className = 'connection-indicator';
  
  const label = document.createElement('span');
  label.className = 'connection-label';
  
  function updateStatus(state) {
    container.className = `connection-status connection-status-${state}`;
    
    const stateLabels = {
      [ConnectionState.OPERATIONAL]: 'Connected',
      [ConnectionState.DEGRADED]: 'Degraded',
      [ConnectionState.OFFLINE]: 'Offline'
    };
    
    label.textContent = stateLabels[state] || 'Unknown';
  }
  
  indicator.appendChild(label);
  container.appendChild(indicator);
  
  // Initial state
  updateStatus(getConnectionState());
  
  // Subscribe to state changes
  const unsubscribe = onConnectionStateChange(updateStatus);
  
  // Cleanup function
  container.cleanup = () => {
    unsubscribe();
  };
  
  return container;
}

export function initConnectionStatus(mountSelector) {
  const mount = document.querySelector(mountSelector);
  if (!mount) {
    console.warn(`Connection status mount point not found: ${mountSelector}`);
    return null;
  }
  
  const component = ConnectionStatus();
  mount.appendChild(component);
  
  return {
    element: component,
    cleanup: () => component.cleanup()
  };
}
