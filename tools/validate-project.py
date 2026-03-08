#!/usr/bin/env python3
"""
Godot Headless Validator (Project Validator)
Comprehensive project health check that validates project.godot and runs sub-validators.
"""

import re
import sys
import subprocess
from pathlib import Path
from typing import Dict, List, Tuple, Set, Optional

class ProjectValidator:
    def __init__(self, project_root: Path):
        self.project_root = project_root
        self.project_godot = project_root / "games" / "ashfall" / "project.godot"
        self.tools_dir = project_root / "tools"
        self.errors: List[str] = []
        self.warnings: List[str] = []
        
    def validate_project_godot_exists(self) -> bool:
        """Check that project.godot exists"""
        if not self.project_godot.exists():
            self.errors.append(f"project.godot not found at {self.project_godot}")
            return False
        print(f"[OK] project.godot found: {self.project_godot}")
        return True
    
    def parse_project_godot(self) -> Dict[str, Dict[str, str]]:
        """Parse project.godot into sections"""
        content = self.project_godot.read_text(encoding='utf-8')
        sections: Dict[str, Dict[str, str]] = {}
        current_section = None
        
        for line in content.split('\n'):
            line = line.strip()
            
            # Section header
            section_match = re.match(r'\[(\w+)\]', line)
            if section_match:
                current_section = section_match.group(1)
                sections[current_section] = {}
                continue
            
            # Key-value pair
            if current_section and '=' in line:
                # Handle both simple and complex values
                key, value = line.split('=', 1)
                key = key.strip()
                value = value.strip()
                sections[current_section][key] = value
        
        return sections
    
    def validate_autoloads(self, sections: Dict[str, Dict[str, str]]) -> bool:
        """Validate [autoload] section"""
        print()
        print("Validating [autoload] section...")
        
        if 'autoload' not in sections:
            self.warnings.append("No [autoload] section found in project.godot")
            print("   [WARN] No [autoload] section found")
            return True
        
        autoload_section = sections['autoload']
        all_valid = True
        
        for name, value in autoload_section.items():
            # Extract path from value (format: "*res://path/to/file.gd" or "res://...")
            path_match = re.search(r'[*]?res://([^"]+)', value)
            if not path_match:
                self.errors.append(f"Autoload '{name}' has invalid path format: {value}")
                print(f"   [FAIL] {name}: Invalid path format")
                all_valid = False
                continue
            
            path = path_match.group(1)
            fs_path = self.project_root / "games" / "ashfall" / path
            
            if not fs_path.exists():
                self.errors.append(f"Autoload '{name}' references missing file: {path}")
                print(f"   [FAIL] {name}: File not found ({path})")
                all_valid = False
            else:
                print(f"   [OK] {name}: {path}")
        
        return all_valid
    
    def validate_input_actions(self, sections: Dict[str, Dict[str, str]]) -> bool:
        """Validate [input] section"""
        print()
        print("Validating [input] section...")
        
        if 'input' not in sections:
            self.warnings.append("No [input] section found in project.godot")
            print("   [WARN] No [input] section found")
            return True
        
        input_section = sections['input']
        all_valid = True
        
        # Check that input actions are well-formed
        for action_name, action_data in input_section.items():
            # Basic validation: must have "events" key
            if 'events' not in action_data:
                self.warnings.append(f"Input action '{action_name}' may be malformed (no 'events' found)")
                print(f"   [WARN] {action_name}: No events defined")
            else:
                print(f"   [OK] {action_name}")
        
        # Check for required fighting game inputs
        required_actions = [
            'p1_left', 'p1_right', 'p1_up', 'p1_down',
            'p1_light_punch', 'p1_heavy_punch',
            'p2_left', 'p2_right', 'p2_up', 'p2_down',
            'p2_light_punch', 'p2_heavy_punch'
        ]
        
        missing_actions = [a for a in required_actions if a not in input_section]
        if missing_actions:
            self.warnings.append(f"Missing expected input actions: {', '.join(missing_actions)}")
            print(f"   [WARN] Missing expected actions: {', '.join(missing_actions)}")
        
        return all_valid
    
    def validate_main_scene(self, sections: Dict[str, Dict[str, str]]) -> bool:
        """Validate that main_scene exists"""
        print()
        print("Validating main scene...")
        
        if 'application' not in sections:
            self.errors.append("No [application] section found in project.godot")
            print("   [FAIL] No [application] section found")
            return False
        
        app_section = sections['application']
        
        if 'run/main_scene' not in app_section:
            self.errors.append("No run/main_scene defined in project.godot")
            print("   [FAIL] No run/main_scene defined")
            return False
        
        main_scene = app_section['run/main_scene']
        # Extract path (format: "res://path/to/scene.tscn")
        path_match = re.search(r'res://([^"]+)', main_scene)
        if not path_match:
            self.errors.append(f"main_scene has invalid path format: {main_scene}")
            print(f"   [FAIL] Invalid path format: {main_scene}")
            return False
        
        path = path_match.group(1)
        fs_path = self.project_root / "games" / "ashfall" / path
        
        if not fs_path.exists():
            self.errors.append(f"main_scene references missing file: {path}")
            print(f"   [FAIL] Main scene not found: {path}")
            return False
        
        print(f"   [OK] Main scene: {path}")
        return True
    
    def validate_scene_structure(self) -> bool:
        """Validate that scene files have valid structure"""
        print()
        print("Validating scene files...")
        
        scenes_dir = self.project_root / "games" / "ashfall" / "scenes"
        if not scenes_dir.exists():
            self.warnings.append(f"Scenes directory not found: {scenes_dir}")
            print(f"   [WARN] Scenes directory not found")
            return True
        
        scene_files = list(scenes_dir.rglob("*.tscn"))
        print(f"   Found {len(scene_files)} scene file(s)")
        
        all_valid = True
        for scene_file in scene_files:
            try:
                content = scene_file.read_text(encoding='utf-8')
                # Basic structure check: must start with [gd_scene
                if not content.strip().startswith('[gd_scene'):
                    self.errors.append(f"Invalid scene file format: {scene_file.relative_to(self.project_root)}")
                    print(f"   [FAIL] Invalid format: {scene_file.name}")
                    all_valid = False
            except Exception as e:
                self.errors.append(f"Error reading scene file {scene_file.relative_to(self.project_root)}: {e}")
                print(f"   [FAIL] Error reading: {scene_file.name}")
                all_valid = False
        
        if all_valid:
            print(f"   [OK] All {len(scene_files)} scene files have valid structure")
        
        return all_valid
    
    def run_autoload_checker(self) -> bool:
        """Run the autoload dependency analyzer as a sub-check"""
        print()
        print("=" * 80)
        print("Running Autoload Dependency Analyzer...")
        print("=" * 80)
        
        autoload_checker = self.tools_dir / "check-autoloads.py"
        if not autoload_checker.exists():
            self.warnings.append("Autoload checker not found, skipping")
            print("   [WARN] check-autoloads.py not found, skipping")
            return True
        
        try:
            result = subprocess.run(
                [sys.executable, str(autoload_checker)],
                cwd=str(self.project_root),
                capture_output=True,
                text=True,
                timeout=30
            )
            
            # Print output
            print(result.stdout)
            if result.stderr:
                print(result.stderr)
            
            if result.returncode != 0:
                self.errors.append("Autoload dependency check failed")
                return False
            
            return True
        except subprocess.TimeoutExpired:
            self.errors.append("Autoload checker timed out")
            print("   [FAIL] Autoload checker timed out")
            return False
        except Exception as e:
            self.warnings.append(f"Error running autoload checker: {e}")
            print(f"   [WARN] Error running autoload checker: {e}")
            return True
    
    def run_signal_validator(self) -> bool:
        """Run the signal wiring validator as a sub-check"""
        print()
        print("=" * 80)
        print("Running Signal Wiring Validator...")
        print("=" * 80)
        
        signal_checker = self.tools_dir / "check-signals.py"
        if not signal_checker.exists():
            self.warnings.append("Signal validator not found, skipping")
            print("   [WARN] check-signals.py not found, skipping")
            return True
        
        try:
            result = subprocess.run(
                [sys.executable, str(signal_checker)],
                cwd=str(self.project_root),
                capture_output=True,
                text=True,
                timeout=30
            )
            
            # Print output
            print(result.stdout)
            if result.stderr:
                print(result.stderr)
            
            # Signal validator returns 1 for warnings, which we treat as non-fatal
            if result.returncode != 0:
                self.warnings.append("Signal wiring validator found issues (non-fatal)")
            
            return True
        except subprocess.TimeoutExpired:
            self.warnings.append("Signal validator timed out")
            print("   [WARN] Signal validator timed out")
            return True
        except Exception as e:
            self.warnings.append(f"Error running signal validator: {e}")
            print(f"   [WARN] Error running signal validator: {e}")
            return True
    
    def run_scene_checker(self) -> bool:
        """Run the scene integrity checker as a sub-check"""
        print()
        print("=" * 80)
        print("Running Scene Integrity Checker...")
        print("=" * 80)
        
        scene_checker = self.tools_dir / "check-scenes.py"
        if not scene_checker.exists():
            self.warnings.append("Scene checker not found, skipping")
            print("   [WARN] check-scenes.py not found, skipping")
            return True
        
        try:
            result = subprocess.run(
                [sys.executable, str(scene_checker)],
                cwd=str(self.project_root),
                capture_output=True,
                text=True,
                timeout=30
            )
            
            # Print output
            print(result.stdout)
            if result.stderr:
                print(result.stderr)
            
            if result.returncode != 0:
                self.warnings.append("Scene integrity checker found issues")
                # Treat scene issues as warnings for now
            
            return True
        except subprocess.TimeoutExpired:
            self.warnings.append("Scene checker timed out")
            print("   [WARN] Scene checker timed out")
            return True
        except Exception as e:
            self.warnings.append(f"Error running scene checker: {e}")
            print(f"   [WARN] Error running scene checker: {e}")
            return True
    
    def print_health_report(self) -> bool:
        """Print comprehensive project health report"""
        print()
        print("=" * 80)
        print("PROJECT HEALTH REPORT")
        print("=" * 80)
        print()
        
        has_errors = len(self.errors) > 0
        has_warnings = len(self.warnings) > 0
        
        if not has_errors and not has_warnings:
            print("[OK] PROJECT STATUS: HEALTHY")
            print()
            print("All validation checks passed!")
            return True
        
        if has_errors:
            print("[FAIL] ERRORS:")
            for error in self.errors:
                print(f"   [*] {error}")
            print()
        
        if has_warnings:
            print("[WARN] WARNINGS:")
            for warning in self.warnings:
                print(f"   [*] {warning}")
            print()
        
        # Summary
        status = "FAILING" if has_errors else "PASSING WITH WARNINGS"
        icon = "[FAIL]" if has_errors else "[WARN]"
        print(f"{icon} PROJECT STATUS: {status}")
        print(f"   Errors: {len(self.errors)}")
        print(f"   Warnings: {len(self.warnings)}")
        print()
        
        return not has_errors
    
    def run(self) -> int:
        """Run full project validation. Returns exit code (0 = success, 1 = failure)"""
        print("=" * 80)
        print("GODOT PROJECT VALIDATOR")
        print("=" * 80)
        print()
        
        # Step 1: Verify project.godot exists
        if not self.validate_project_godot_exists():
            return 1
        
        # Step 2: Parse project.godot
        print()
        print("Parsing project.godot...")
        sections = self.parse_project_godot()
        print(f"   Found {len(sections)} section(s): {', '.join(sections.keys())}")
        
        # Step 3: Validate project.godot contents
        self.validate_autoloads(sections)
        self.validate_input_actions(sections)
        self.validate_main_scene(sections)
        self.validate_scene_structure()
        
        # Step 4: Run sub-validators
        self.run_autoload_checker()
        self.run_signal_validator()
        self.run_scene_checker()
        
        # Step 5: Print health report
        all_passed = self.print_health_report()
        
        if all_passed:
            print("=" * 80)
            print("[OK] PROJECT VALIDATION PASSED")
            print("=" * 80)
            return 0
        else:
            print("=" * 80)
            print("[FAIL] PROJECT VALIDATION FAILED")
            print("=" * 80)
            return 1


def main():
    # Find project root
    current = Path(__file__).parent.parent
    
    validator = ProjectValidator(current)
    exit_code = validator.run()
    sys.exit(exit_code)


if __name__ == "__main__":
    main()
