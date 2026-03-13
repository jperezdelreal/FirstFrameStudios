// Global error boundary for catching component errors

class ErrorBoundary {
  constructor() {
    this.errorHandlers = [];
    this.errors = [];
    this.setupGlobalErrorHandler();
  }

  setupGlobalErrorHandler() {
    if (typeof window !== 'undefined') {
      window.addEventListener('error', (event) => {
        this.captureError({
          type: 'uncaught_error',
          message: event.message,
          filename: event.filename,
          lineno: event.lineno,
          colno: event.colno,
          stack: event.error?.stack || ''
        });
      });

      window.addEventListener('unhandledrejection', (event) => {
        this.captureError({
          type: 'unhandled_rejection',
          message: event.reason?.message || String(event.reason),
          stack: event.reason?.stack || ''
        });
      });
    }
  }

  captureError(errorInfo) {
    const timestamp = new Date().toISOString();
    const errorData = { ...errorInfo, timestamp };
    
    this.errors.push(errorData);
    
    // Keep only last 50 errors
    if (this.errors.length > 50) {
      this.errors.shift();
    }
    
    console.error('ErrorBoundary captured error:', errorData);
    
    // Notify all error handlers
    this.errorHandlers.forEach(handler => {
      try {
        handler(errorData);
      } catch (err) {
        console.error('Error in error handler:', err);
      }
    });
  }

  onError(callback) {
    this.errorHandlers.push(callback);
    return () => {
      this.errorHandlers = this.errorHandlers.filter(cb => cb !== callback);
    };
  }

  getErrors() {
    return [...this.errors];
  }

  clearErrors() {
    this.errors = [];
  }

  getLastError() {
    return this.errors[this.errors.length - 1] || null;
  }
}

export const errorBoundary = new ErrorBoundary();

export function initErrorBoundary() {
  // Setup global error handler
  errorBoundary.onError((error) => {
    // Could send to remote logging here
    if (typeof window !== 'undefined' && window.__errorLog) {
      window.__errorLog(error);
    }
  });

  return errorBoundary;
}
