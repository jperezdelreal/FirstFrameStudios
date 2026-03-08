#!/usr/bin/env python3
"""
Signal Wiring Validator
Scans GDScript files to find signal definitions, emissions, and connections.
Reports orphaned signals (emitted but never connected, or connected but never emitted).
"""

import re
import sys
from pathlib import Path
from typing import Dict, List, Set, Tuple
from dataclasses import dataclass, field

@dataclass
class Signal:
    name: str
    defined_in: List[str] = field(default_factory=list)
    emitted_in: List[str] = field(default_factory=list)
    connected_in: List[str] = field(default_factory=list)


class SignalAnalyzer:
    def __init__(self, project_root: Path):
        self.project_root = project_root
        self.scripts_dir = project_root / "games" / "ashfall" / "scripts"
        self.signals: Dict[str, Signal] = {}
        
    def find_gd_files(self) -> List[Path]:
        """Recursively find all .gd files in scripts directory"""
        if not self.scripts_dir.exists():
            print(f"[WARN] WARNING: Scripts directory not found: {self.scripts_dir}")
            # Try alternate location
            alt_dir = self.project_root / "games" / "ashfall" / "src"
            if alt_dir.exists():
                self.scripts_dir = alt_dir
                print(f"   Using alternate directory: {self.scripts_dir}")
            else:
                return []
                
        gd_files = list(self.scripts_dir.rglob("*.gd"))
        print(f"[*] Found {len(gd_files)} GDScript file(s)")
        return gd_files
    
    def scan_signals(self, files: List[Path]):
        """Scan all files for signal definitions, emissions, and connections"""
        
        for file_path in files:
            rel_path = file_path.relative_to(self.project_root)
            content = file_path.read_text(encoding='utf-8', errors='ignore')
            
            # 1. Find signal definitions
            # Pattern: signal signal_name or signal signal_name(params)
            signal_defs = re.findall(r'^\s*signal\s+(\w+)', content, re.MULTILINE)
            for sig_name in signal_defs:
                if sig_name not in self.signals:
                    self.signals[sig_name] = Signal(name=sig_name)
                self.signals[sig_name].defined_in.append(str(rel_path))
            
            # 2. Find signal emissions (Godot 4 style)
            # Patterns:
            #   - signal_name.emit(...)
            #   - EventBus.signal_name.emit(...)
            #   - emit_signal("signal_name", ...)
            
            # Godot 4 typed signal emit: signal_name.emit(...)
            typed_emits = re.findall(r'(\w+)\.emit\s*\(', content)
            for sig_name in typed_emits:
                # Filter out common false positives (methods that aren't signals)
                if sig_name not in ['print', 'push_warning', 'push_error', 'assert']:
                    if sig_name not in self.signals:
                        self.signals[sig_name] = Signal(name=sig_name)
                    self.signals[sig_name].emitted_in.append(str(rel_path))
            
            # EventBus style: EventBus.signal_name.emit(...)
            eventbus_emits = re.findall(r'EventBus\.(\w+)\.emit\s*\(', content)
            for sig_name in eventbus_emits:
                if sig_name not in self.signals:
                    self.signals[sig_name] = Signal(name=sig_name)
                self.signals[sig_name].emitted_in.append(str(rel_path))
            
            # Old style: emit_signal("signal_name", ...)
            legacy_emits = re.findall(r'emit_signal\s*\(\s*["\'](\w+)["\']', content)
            for sig_name in legacy_emits:
                if sig_name not in self.signals:
                    self.signals[sig_name] = Signal(name=sig_name)
                self.signals[sig_name].emitted_in.append(str(rel_path))
            
            # 3. Find signal connections
            # Patterns:
            #   - signal_name.connect(...)
            #   - EventBus.signal_name.connect(...)
            #   - node.connect("signal_name", ...)
            
            # Typed signal connect: signal_name.connect(...)
            typed_connects = re.findall(r'(\w+)\.connect\s*\(', content)
            for sig_name in typed_connects:
                if sig_name not in ['print', 'push_warning']:
                    if sig_name not in self.signals:
                        self.signals[sig_name] = Signal(name=sig_name)
                    self.signals[sig_name].connected_in.append(str(rel_path))
            
            # EventBus style: EventBus.signal_name.connect(...)
            eventbus_connects = re.findall(r'EventBus\.(\w+)\.connect\s*\(', content)
            for sig_name in eventbus_connects:
                if sig_name not in self.signals:
                    self.signals[sig_name] = Signal(name=sig_name)
                self.signals[sig_name].connected_in.append(str(rel_path))
            
            # Old style: connect("signal_name", ...)
            legacy_connects = re.findall(r'\.connect\s*\(\s*["\'](\w+)["\']', content)
            for sig_name in legacy_connects:
                if sig_name not in self.signals:
                    self.signals[sig_name] = Signal(name=sig_name)
                self.signals[sig_name].connected_in.append(str(rel_path))
    
    def analyze_wiring(self) -> Tuple[List[str], List[str], List[str]]:
        """
        Analyze signal wiring and categorize issues.
        Returns: (orphaned_emits, orphaned_connects, healthy_signals)
        """
        orphaned_emits = []
        orphaned_connects = []
        healthy = []
        
        for sig_name, signal in self.signals.items():
            has_emit = bool(signal.emitted_in)
            has_connect = bool(signal.connected_in)
            has_definition = bool(signal.defined_in)
            
            if has_emit and not has_connect:
                orphaned_emits.append(sig_name)
            elif has_connect and not has_emit:
                orphaned_connects.append(sig_name)
            elif has_emit and has_connect:
                healthy.append(sig_name)
        
        return orphaned_emits, orphaned_connects, healthy
    
    def print_wiring_matrix(self):
        """Print a detailed wiring matrix showing all signals"""
        print()
        print("=" * 80)
        print("[*] SIGNAL WIRING MATRIX")
        print("=" * 80)
        print()
        
        if not self.signals:
            print("[WARN] No signals found")
            return
        
        # Sort signals by name
        sorted_signals = sorted(self.signals.items())
        
        for sig_name, signal in sorted_signals:
            has_def = bool(signal.defined_in)
            has_emit = bool(signal.emitted_in)
            has_connect = bool(signal.connected_in)
            
            # Status indicator
            if has_emit and has_connect:
                status = "[OK]"
            elif has_emit and not has_connect:
                status = "[WARN]"
            elif has_connect and not has_emit:
                status = "[WARN]"
            else:
                status = "[?]"
            
            print(f"{status} {sig_name}")
            
            if signal.defined_in:
                print(f"   [DEF] Defined in:")
                for path in set(signal.defined_in):
                    print(f"      - {path}")
            
            if signal.emitted_in:
                print(f"   [EMIT] Emitted in:")
                for path in set(signal.emitted_in):
                    print(f"      - {path}")
            
            if signal.connected_in:
                print(f"   [CONN] Connected in:")
                for path in set(signal.connected_in):
                    print(f"      - {path}")
            
            if not has_emit:
                print(f"   [WARN] WARNING: Signal is connected but never emitted")
            if not has_connect:
                print(f"   [WARN] WARNING: Signal is emitted but never connected")
            
            print()
    
    def run(self) -> int:
        """Run full analysis. Returns exit code (0 = success, 1 = warnings found)"""
        print("=" * 80)
        print("[*] SIGNAL WIRING VALIDATOR")
        print("=" * 80)
        print()
        
        # Find all GDScript files
        gd_files = self.find_gd_files()
        if not gd_files:
            print("[FAIL] ERROR: No GDScript files found")
            return 1
        
        print()
        
        # Scan for signals
        print("[*] Scanning for signals...")
        self.scan_signals(gd_files)
        print(f"   Found {len(self.signals)} unique signal(s)")
        print()
        
        # Analyze wiring
        orphaned_emits, orphaned_connects, healthy = self.analyze_wiring()
        
        # Print wiring matrix
        self.print_wiring_matrix()
        
        # Summary
        print("=" * 80)
        print("[*] SUMMARY")
        print("=" * 80)
        print()
        print(f"[OK] Healthy signals (emitted AND connected): {len(healthy)}")
        print(f"[WARN] Orphaned emissions (emitted but not connected): {len(orphaned_emits)}")
        print(f"[WARN] Orphaned connections (connected but not emitted): {len(orphaned_connects)}")
        print()
        
        if orphaned_emits:
            print("[WARN] ORPHANED EMISSIONS:")
            for sig in sorted(orphaned_emits):
                print(f"   - {sig}")
                print(f"     Emitted in: {', '.join(set(self.signals[sig].emitted_in))}")
            print()
        
        if orphaned_connects:
            print("[WARN] ORPHANED CONNECTIONS:")
            for sig in sorted(orphaned_connects):
                print(f"   - {sig}")
                print(f"     Connected in: {', '.join(set(self.signals[sig].connected_in))}")
            print()
        
        # Return status
        if orphaned_emits or orphaned_connects:
            print("=" * 80)
            print("[WARN] WARNINGS DETECTED")
            print("=" * 80)
            print()
            print("Some signals are not properly wired. This may indicate:")
            print("  - Dead code (emitted signals with no listeners)")
            print("  - Missing functionality (connected signals that are never emitted)")
            print()
            return 1
        else:
            print("=" * 80)
            print("[OK] ALL SIGNALS PROPERLY WIRED")
            print("=" * 80)
            return 0


def main():
    # Find project root
    current = Path(__file__).parent.parent
    
    analyzer = SignalAnalyzer(current)
    exit_code = analyzer.run()
    sys.exit(exit_code)


if __name__ == "__main__":
    main()
