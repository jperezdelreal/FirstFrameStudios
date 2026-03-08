#!/usr/bin/env python3
"""
Tool 13: Live Reload Watcher (#45)
Watches for file changes and provides notifications.
Author: Jango (Lead, Tool Engineer)
"""

import os
import sys
import time
from datetime import datetime
from pathlib import Path
from typing import Set, Optional

ASHFALL_ROOT = Path(__file__).parent.parent / "games" / "ashfall"
WATCH_DIR = ASHFALL_ROOT / "scripts"
WATCH_EXTENSIONS = [".gd", ".tscn"]
POLL_INTERVAL = 1.0  # seconds

# Try to import watchdog, fall back to polling if not available
try:
    from watchdog.observers import Observer
    from watchdog.events import FileSystemEventHandler
    WATCHDOG_AVAILABLE = True
except ImportError:
    WATCHDOG_AVAILABLE = False

class FileChangeHandler(FileSystemEventHandler):
    """Handler for watchdog file system events"""
    
    def __init__(self, on_change_callback):
        self.on_change_callback = on_change_callback
    
    def on_modified(self, event):
        if event.is_directory:
            return
        
        file_path = Path(event.src_path)
        if file_path.suffix in WATCH_EXTENSIONS:
            self.on_change_callback(file_path, "modified")
    
    def on_created(self, event):
        if event.is_directory:
            return
        
        file_path = Path(event.src_path)
        if file_path.suffix in WATCH_EXTENSIONS:
            self.on_change_callback(file_path, "created")
    
    def on_deleted(self, event):
        if event.is_directory:
            return
        
        file_path = Path(event.src_path)
        if file_path.suffix in WATCH_EXTENSIONS:
            self.on_change_callback(file_path, "deleted")

def format_timestamp() -> str:
    """Format current timestamp"""
    return datetime.now().strftime("%H:%M:%S")

def on_file_change(file_path: Path, change_type: str):
    """Callback when a file changes"""
    timestamp = format_timestamp()
    rel_path = file_path.relative_to(ASHFALL_ROOT)
    
    emoji = {
        "modified": "📝",
        "created": "✨",
        "deleted": "🗑️"
    }.get(change_type, "📄")
    
    print(f"{emoji} [{timestamp}] {change_type.upper()}: {rel_path}")

def watch_with_watchdog():
    """Watch files using watchdog library"""
    print("🔧 Tool 13: Live Reload Watcher (watchdog mode)")
    print("="*80)
    print(f"👀 Watching: {WATCH_DIR}")
    print(f"📋 Extensions: {', '.join(WATCH_EXTENSIONS)}")
    print("🔄 Waiting for file changes... (Press Ctrl+C to stop)")
    print("="*80)
    print()
    
    event_handler = FileChangeHandler(on_file_change)
    observer = Observer()
    observer.schedule(event_handler, str(WATCH_DIR), recursive=True)
    observer.start()
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\n\n⏹️  Stopping watcher...")
        observer.stop()
    
    observer.join()
    print("✅ Watcher stopped.")

def watch_with_polling():
    """Watch files using basic polling (fallback)"""
    print("🔧 Tool 13: Live Reload Watcher (polling mode)")
    print("="*80)
    print(f"👀 Watching: {WATCH_DIR}")
    print(f"📋 Extensions: {', '.join(WATCH_EXTENSIONS)}")
    print("⚠️  NOTE: Using polling (install watchdog for better performance)")
    print("   pip install watchdog")
    print("🔄 Waiting for file changes... (Press Ctrl+C to stop)")
    print("="*80)
    print()
    
    # Build initial file state
    file_mtimes: dict[Path, float] = {}
    
    def scan_files():
        """Scan all watched files"""
        for ext in WATCH_EXTENSIONS:
            pattern = f"**/*{ext}"
            for file_path in WATCH_DIR.rglob(pattern):
                try:
                    mtime = file_path.stat().st_mtime
                    file_mtimes[file_path] = mtime
                except Exception:
                    pass
    
    # Initial scan
    scan_files()
    print(f"📊 Tracking {len(file_mtimes)} files")
    print()
    
    try:
        while True:
            time.sleep(POLL_INTERVAL)
            
            # Check for modifications and new files
            for ext in WATCH_EXTENSIONS:
                pattern = f"**/*{ext}"
                for file_path in WATCH_DIR.rglob(pattern):
                    try:
                        mtime = file_path.stat().st_mtime
                        
                        if file_path not in file_mtimes:
                            # New file
                            file_mtimes[file_path] = mtime
                            on_file_change(file_path, "created")
                        elif mtime > file_mtimes[file_path]:
                            # Modified file
                            file_mtimes[file_path] = mtime
                            on_file_change(file_path, "modified")
                    
                    except Exception:
                        pass
            
            # Check for deleted files
            existing_files = set()
            for ext in WATCH_EXTENSIONS:
                pattern = f"**/*{ext}"
                existing_files.update(WATCH_DIR.rglob(pattern))
            
            deleted_files = set(file_mtimes.keys()) - existing_files
            for file_path in deleted_files:
                del file_mtimes[file_path]
                on_file_change(file_path, "deleted")
    
    except KeyboardInterrupt:
        print("\n\n⏹️  Stopping watcher...")
    
    print("✅ Watcher stopped.")

def main():
    # Check if watch directory exists
    if not WATCH_DIR.exists():
        print(f"❌ Watch directory not found: {WATCH_DIR}")
        return 1
    
    # Use watchdog if available, otherwise fall back to polling
    if WATCHDOG_AVAILABLE:
        watch_with_watchdog()
    else:
        watch_with_polling()
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
