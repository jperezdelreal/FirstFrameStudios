#!/usr/bin/env python3
"""
Autoload Dependency Analyzer
Validates autoload order in project.godot matches dependency graph.
"""

import re
import sys
from pathlib import Path
from typing import Dict, List, Set, Tuple

class AutoloadAnalyzer:
    def __init__(self, project_root: Path):
        self.project_root = project_root
        self.project_godot = project_root / "games" / "ashfall" / "project.godot"
        self.autoloads: List[Tuple[str, str]] = []  # (name, path)
        self.dependencies: Dict[str, Set[str]] = {}  # name -> set of dependencies
        
    def parse_autoloads(self) -> bool:
        """Extract autoload entries from project.godot"""
        if not self.project_godot.exists():
            print(f"❌ ERROR: project.godot not found at {self.project_godot}")
            return False
            
        content = self.project_godot.read_text(encoding='utf-8')
        
        # Find [autoload] section
        autoload_section = re.search(r'\[autoload\](.*?)(?=\[|\Z)', content, re.DOTALL)
        if not autoload_section:
            print("⚠️  WARNING: No [autoload] section found in project.godot")
            return True
            
        # Parse autoload entries
        # Format: AutoloadName="*res://path/to/script.gd"
        pattern = r'(\w+)="?\*?res://([^"]+)"?'
        matches = re.findall(pattern, autoload_section.group(1))
        
        for name, path in matches:
            self.autoloads.append((name, path))
            
        if not self.autoloads:
            print("⚠️  WARNING: No autoloads defined")
            return True
            
        print(f"📋 Found {len(self.autoloads)} autoload(s):")
        for name, path in self.autoloads:
            print(f"   - {name}: {path}")
        print()
        
        return True
    
    def verify_files_exist(self) -> bool:
        """Check that all autoload script files exist"""
        all_exist = True
        
        for name, path in self.autoloads:
            # Convert res:// path to filesystem path
            fs_path = self.project_root / "games" / "ashfall" / path
            
            if not fs_path.exists():
                print(f"❌ ERROR: Autoload '{name}' references missing file: {path}")
                all_exist = False
            else:
                print(f"✅ {name}: File exists")
                
        print()
        return all_exist
    
    def extract_dependencies(self) -> bool:
        """Parse each autoload script to find dependencies on other autoloads"""
        for name, path in self.autoloads:
            fs_path = self.project_root / "games" / "ashfall" / path
            
            if not fs_path.exists():
                continue
                
            deps = set()
            content = fs_path.read_text(encoding='utf-8')
            
            # Look for references to other autoloads
            # Common patterns: EventBus.something, GameState.something, etc.
            for other_name, _ in self.autoloads:
                if other_name == name:
                    continue
                    
                # Check if this autoload is referenced
                # Pattern: AutoloadName. or AutoloadName[
                pattern = rf'\b{other_name}\s*[.\[]'
                if re.search(pattern, content):
                    deps.add(other_name)
                    
            self.dependencies[name] = deps
            
        return True
    
    def validate_order(self) -> Tuple[bool, List[str]]:
        """
        Validate that autoloads are ordered correctly based on dependencies.
        Returns (is_valid, violations)
        """
        violations = []
        
        # Build position map
        positions = {name: i for i, (name, _) in enumerate(self.autoloads)}
        
        print("🔍 Dependency Analysis:")
        for name, deps in self.dependencies.items():
            if deps:
                print(f"   {name} depends on: {', '.join(sorted(deps))}")
                
                # Check that all dependencies come before this autoload
                my_pos = positions[name]
                for dep in deps:
                    dep_pos = positions.get(dep)
                    if dep_pos is None:
                        violations.append(f"{name} depends on {dep}, but {dep} is not an autoload")
                    elif dep_pos > my_pos:
                        violations.append(
                            f"{name} (position {my_pos}) depends on {dep} (position {dep_pos}), "
                            f"but {dep} loads AFTER {name}"
                        )
            else:
                print(f"   {name}: No dependencies")
        
        print()
        
        if violations:
            print("❌ VALIDATION FAILED: Dependency order violations detected")
            for v in violations:
                print(f"   - {v}")
            print()
            return False, violations
        
        print("✅ Autoload order is valid!")
        return True, []
    
    def suggest_correct_order(self) -> List[str]:
        """Perform topological sort to suggest correct order"""
        # Simple topological sort
        visited = set()
        result = []
        
        def visit(name):
            if name in visited:
                return
            visited.add(name)
            
            # Visit dependencies first
            for dep in self.dependencies.get(name, []):
                visit(dep)
                
            result.append(name)
        
        # Visit all autoloads
        for name, _ in self.autoloads:
            visit(name)
            
        return result
    
    def run(self) -> int:
        """Run full analysis. Returns exit code (0 = success, 1 = failure)"""
        print("=" * 60)
        print("🔧 AUTOLOAD DEPENDENCY ANALYZER")
        print("=" * 60)
        print()
        
        # Step 1: Parse autoloads
        if not self.parse_autoloads():
            return 1
            
        # Step 2: Verify files exist
        if not self.verify_files_exist():
            return 1
            
        # Step 3: Extract dependencies
        self.extract_dependencies()
        
        # Step 4: Validate order
        is_valid, violations = self.validate_order()
        
        if not is_valid:
            # Suggest correct order
            print("💡 SUGGESTED ORDER (based on dependencies):")
            correct_order = self.suggest_correct_order()
            for i, name in enumerate(correct_order, 1):
                # Find the path for this autoload
                path = next(p for n, p in self.autoloads if n == name)
                print(f"   {i}. {name} = *res://{path}")
            print()
            return 1
            
        print("=" * 60)
        print("✅ ALL CHECKS PASSED")
        print("=" * 60)
        return 0


def main():
    # Find project root (go up until we find games/ashfall)
    current = Path(__file__).parent.parent
    
    analyzer = AutoloadAnalyzer(current)
    exit_code = analyzer.run()
    sys.exit(exit_code)


if __name__ == "__main__":
    main()
