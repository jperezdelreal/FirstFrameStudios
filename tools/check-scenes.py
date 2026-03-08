#!/usr/bin/env python3
"""
Scene Integrity Checker
Validates .tscn files for broken script references and collision layer configuration.
"""

import re
import sys
from pathlib import Path
from typing import Dict, List, Tuple, Set
from dataclasses import dataclass, field

@dataclass
class SceneIssue:
    scene_file: str
    line_number: int
    issue_type: str
    message: str

class SceneChecker:
    def __init__(self, project_root: Path):
        self.project_root = project_root
        self.scenes_dir = project_root / "games" / "ashfall" / "scenes"
        self.issues: List[SceneIssue] = []
        
        # Expected collision layer configuration
        self.layer_names = {
            1: "Fighters",
            2: "Hitboxes", 
            3: "Hurtboxes",
            4: "Stage"
        }
        
    def find_scene_files(self) -> List[Path]:
        """Recursively find all .tscn files in scenes directory"""
        if not self.scenes_dir.exists():
            print(f"[FAIL] ERROR: Scenes directory not found: {self.scenes_dir}")
            return []
            
        scene_files = list(self.scenes_dir.rglob("*.tscn"))
        print(f"[*] Found {len(scene_files)} scene file(s)")
        return scene_files
    
    def extract_script_references(self, scene_path: Path) -> List[Tuple[int, str]]:
        """
        Extract script references from scene file.
        Returns list of (line_number, script_path) tuples.
        """
        script_refs = []
        content = scene_path.read_text(encoding='utf-8')
        
        # Pattern 1: [ext_resource type="Script" path="res://..."]
        # Pattern 2: script = ExtResource("...")
        lines = content.split('\n')
        ext_resources = {}  # id -> path mapping
        
        for line_num, line in enumerate(lines, 1):
            # Parse ext_resource definitions
            ext_match = re.search(r'\[ext_resource\s+type="Script"\s+path="(res://[^"]+)"\s+id="([^"]+)"\]', line)
            if ext_match:
                script_path = ext_match.group(1)
                resource_id = ext_match.group(2)
                ext_resources[resource_id] = script_path
                script_refs.append((line_num, script_path))
            
            # Parse inline script references (less common but possible)
            inline_match = re.search(r'script\s*=\s*"(res://[^"]+\.gd)"', line)
            if inline_match:
                script_path = inline_match.group(1)
                script_refs.append((line_num, script_path))
        
        return script_refs
    
    def verify_script_exists(self, script_path: str) -> bool:
        """Check if a script file exists on disk"""
        # Convert res:// path to filesystem path
        rel_path = script_path.replace("res://", "")
        fs_path = self.project_root / "games" / "ashfall" / rel_path
        return fs_path.exists()
    
    def extract_collision_info(self, scene_path: Path) -> List[Tuple[int, str, int, int]]:
        """
        Extract collision layer/mask configuration from scene.
        Returns list of (line_number, node_name, collision_layer, collision_mask) tuples.
        """
        collision_info = []
        content = scene_path.read_text(encoding='utf-8')
        lines = content.split('\n')
        
        current_node = None
        current_line = 0
        collision_layer = None
        collision_mask = None
        
        for line_num, line in enumerate(lines, 1):
            # Detect node definition
            node_match = re.match(r'\[node\s+name="([^"]+)"', line)
            if node_match:
                # Save previous node if it had collision info
                if current_node and (collision_layer is not None or collision_mask is not None):
                    collision_info.append((
                        current_line,
                        current_node,
                        collision_layer if collision_layer is not None else 1,  # Default is 1
                        collision_mask if collision_mask is not None else 1
                    ))
                
                # Start tracking new node
                current_node = node_match.group(1)
                current_line = line_num
                collision_layer = None
                collision_mask = None
            
            # Extract collision_layer
            layer_match = re.match(r'collision_layer\s*=\s*(\d+)', line)
            if layer_match and current_node:
                collision_layer = int(layer_match.group(1))
            
            # Extract collision_mask
            mask_match = re.match(r'collision_mask\s*=\s*(\d+)', line)
            if mask_match and current_node:
                collision_mask = int(mask_match.group(1))
        
        # Don't forget the last node
        if current_node and (collision_layer is not None or collision_mask is not None):
            collision_info.append((
                current_line,
                current_node,
                collision_layer if collision_layer is not None else 1,
                collision_mask if collision_mask is not None else 1
            ))
        
        return collision_info
    
    def validate_collision_layers(self, scene_path: Path, collision_info: List[Tuple[int, str, int, int]]):
        """Validate collision layer configuration against expected scheme"""
        rel_path = scene_path.relative_to(self.project_root)
        
        for line_num, node_name, layer, mask in collision_info:
            # Check if using default layer 1 inappropriately
            # Fighters should use layer 1, hitboxes should use 2, hurtboxes should use 4, stage should use 8
            
            # Detect node types based on name
            node_lower = node_name.lower()
            
            if 'hitbox' in node_lower:
                if layer != 2:
                    self.issues.append(SceneIssue(
                        scene_file=str(rel_path),
                        line_number=line_num,
                        issue_type="COLLISION_LAYER",
                        message=f"Hitbox node '{node_name}' should use collision_layer = 2 (Hitboxes), found {layer}"
                    ))
                if mask != 4:  # Hitboxes should collide with Hurtboxes
                    self.issues.append(SceneIssue(
                        scene_file=str(rel_path),
                        line_number=line_num,
                        issue_type="COLLISION_MASK",
                        message=f"Hitbox node '{node_name}' should use collision_mask = 4 (Hurtboxes), found {mask}"
                    ))
            
            elif 'hurtbox' in node_lower:
                if layer != 4:
                    self.issues.append(SceneIssue(
                        scene_file=str(rel_path),
                        line_number=line_num,
                        issue_type="COLLISION_LAYER",
                        message=f"Hurtbox node '{node_name}' should use collision_layer = 4 (Hurtboxes), found {layer}"
                    ))
                if mask != 2:  # Hurtboxes should collide with Hitboxes
                    self.issues.append(SceneIssue(
                        scene_file=str(rel_path),
                        line_number=line_num,
                        issue_type="COLLISION_MASK",
                        message=f"Hurtbox node '{node_name}' should use collision_mask = 2 (Hitboxes), found {mask}"
                    ))
            
            elif 'stage' in node_lower or 'floor' in node_lower or 'wall' in node_lower:
                if layer != 8:
                    self.issues.append(SceneIssue(
                        scene_file=str(rel_path),
                        line_number=line_num,
                        issue_type="COLLISION_LAYER",
                        message=f"Stage node '{node_name}' should use collision_layer = 8 (Stage), found {layer}"
                    ))
            
            elif 'fighter' in node_lower:
                # Fighters should be on layer 1 and collide with other fighters (1) and stage (8)
                if layer != 1 and layer != 0:  # 0 means using default
                    if layer != 1:
                        self.issues.append(SceneIssue(
                            scene_file=str(rel_path),
                            line_number=line_num,
                            issue_type="COLLISION_LAYER",
                            message=f"Fighter node '{node_name}' should use collision_layer = 1 (Fighters), found {layer}"
                        ))
                
                # Fighter mask should typically be 1 (other fighters) + 8 (stage) = 9
                expected_mask = 9
                if mask != expected_mask and mask != 0:
                    self.issues.append(SceneIssue(
                        scene_file=str(rel_path),
                        line_number=line_num,
                        issue_type="COLLISION_MASK",
                        message=f"Fighter node '{node_name}' should use collision_mask = {expected_mask} (Fighters + Stage), found {mask}"
                    ))
    
    def check_scene(self, scene_path: Path) -> bool:
        """Check a single scene file. Returns True if passed, False if issues found."""
        rel_path = scene_path.relative_to(self.project_root)
        scene_passed = True
        
        # 1. Check script references
        script_refs = self.extract_script_references(scene_path)
        for line_num, script_path in script_refs:
            if not self.verify_script_exists(script_path):
                self.issues.append(SceneIssue(
                    scene_file=str(rel_path),
                    line_number=line_num,
                    issue_type="MISSING_SCRIPT",
                    message=f"Script not found: {script_path}"
                ))
                scene_passed = False
        
        # 2. Check collision layer configuration
        collision_info = self.extract_collision_info(scene_path)
        self.validate_collision_layers(scene_path, collision_info)
        
        return scene_passed
    
    def print_report(self) -> bool:
        """Print detailed report. Returns True if all checks passed."""
        print()
        print("=" * 80)
        print("[*] SCENE INTEGRITY REPORT")
        print("=" * 80)
        print()
        
        if not self.issues:
            print("[OK] All scenes passed integrity checks!")
            print()
            return True
        
        # Group issues by scene
        issues_by_scene: Dict[str, List[SceneIssue]] = {}
        for issue in self.issues:
            if issue.scene_file not in issues_by_scene:
                issues_by_scene[issue.scene_file] = []
            issues_by_scene[issue.scene_file].append(issue)
        
        # Print issues grouped by scene
        for scene_file in sorted(issues_by_scene.keys()):
            scene_issues = issues_by_scene[scene_file]
            print(f"[FAIL] {scene_file}")
            
            for issue in scene_issues:
                icon = "[FAIL]" if issue.issue_type == "MISSING_SCRIPT" else "[WARN]"
                print(f"   {icon} Line {issue.line_number}: [{issue.issue_type}] {issue.message}")
            
            print()
        
        # Summary
        print("=" * 80)
        print("[*] SUMMARY")
        print("=" * 80)
        print()
        
        missing_scripts = len([i for i in self.issues if i.issue_type == "MISSING_SCRIPT"])
        collision_issues = len([i for i in self.issues if i.issue_type.startswith("COLLISION")])
        
        print(f"[FAIL] Missing scripts: {missing_scripts}")
        print(f"[WARN] Collision layer/mask issues: {collision_issues}")
        print(f"📝 Total issues: {len(self.issues)}")
        print()
        
        return False
    
    def run(self) -> int:
        """Run full scene check. Returns exit code (0 = success, 1 = issues found)"""
        print("=" * 80)
        print("[*] SCENE INTEGRITY CHECKER")
        print("=" * 80)
        print()
        
        # Find all scene files
        scene_files = self.find_scene_files()
        if not scene_files:
            print("[FAIL] ERROR: No scene files found")
            return 1
        
        print()
        
        # Check each scene
        print("[*] Checking scenes...")
        for scene_path in scene_files:
            rel_path = scene_path.relative_to(self.project_root)
            self.check_scene(scene_path)
            print(f"   [OK] {rel_path}")
        
        print()
        
        # Print report
        all_passed = self.print_report()
        
        if all_passed:
            print("=" * 80)
            print("[OK] ALL SCENE CHECKS PASSED")
            print("=" * 80)
            return 0
        else:
            print("=" * 80)
            print("[FAIL] SCENE INTEGRITY ISSUES DETECTED")
            print("=" * 80)
            return 1


def main():
    # Find project root
    current = Path(__file__).parent.parent
    
    checker = SceneChecker(current)
    exit_code = checker.run()
    sys.exit(exit_code)


if __name__ == "__main__":
    main()
