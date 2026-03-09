#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
#!/usr/bin/env python3
"""
Tool 10: GDD Diff Reporter (#41)
Compares GDD specs against actual implementation.
Author: Jango (Lead, Tool Engineer)
"""

import os
import re
import sys
from pathlib import Path
from typing import Dict, Any, List

ASHFALL_ROOT = Path(__file__).parent.parent / "games" / "ashfall"
GDD_PATH = ASHFALL_ROOT / "docs" / "GDD.md"
PROJECT_GODOT = ASHFALL_ROOT / "project.godot"

class GDDSpec:
    """GDD specification values"""
    def __init__(self):
        self.health_per_round = 1000
        self.rounds_to_win = 2
        self.round_timer = 60
        self.max_ember = 100
        self.physics_fps = 60
        self.button_count = 6  # LP, MP, HP, LK, MK, HK
        self.num_players = 2
        self.num_characters_mvp = 2  # Kael and Rhena for MVP
        self.num_stages_mvp = 1
        self.collision_layers = ["Fighters", "Hitboxes", "Hurtboxes", "Stage"]
        self.required_autoloads = [
            "EventBus",
            "GameState", 
            "RoundManager",
            "VFXManager",
            "AudioManager",
            "SceneManager"
        ]

class ProjectSpec:
    """Actual implementation values"""
    def __init__(self):
        self.physics_fps = None
        self.button_count_p1 = 0
        self.button_count_p2 = 0
        self.collision_layers = []
        self.autoloads = []
        self.viewport_width = None
        self.viewport_height = None

def parse_gdd() -> GDDSpec:
    """Parse GDD.md for specifications"""
    print("📖 Parsing GDD.md...")
    
    if not GDD_PATH.exists():
        print(f"❌ GDD not found at {GDD_PATH}")
        return GDDSpec()
    
    gdd_content = GDD_PATH.read_text(encoding="utf-8")
    spec = GDDSpec()
    
    # Parse key values from GDD
    # Health
    health_match = re.search(r'\*\*Health per round:\*\* (\d+) HP', gdd_content)
    if health_match:
        spec.health_per_round = int(health_match.group(1))
    
    # Round timer
    timer_match = re.search(r'\*\*Round timer:\*\* (\d+) seconds', gdd_content)
    if timer_match:
        spec.round_timer = int(timer_match.group(1))
    
    # Best of X rounds
    rounds_match = re.search(r'\*\*Best of (\d+) rounds\*\*', gdd_content)
    if rounds_match:
        total_rounds = int(rounds_match.group(1))
        spec.rounds_to_win = (total_rounds // 2) + 1
    
    # Max Ember
    ember_match = re.search(r'\*\*Maximum Ember:\*\* (\d+) per player', gdd_content)
    if ember_match:
        spec.max_ember = int(ember_match.group(1))
    
    print(f"✅ GDD parsed: {spec.health_per_round}HP, {spec.round_timer}s timer, Bo{spec.rounds_to_win*2-1}")
    return spec

def parse_project_godot() -> ProjectSpec:
    """Parse project.godot for actual implementation"""
    print("🔍 Parsing project.godot...")
    
    if not PROJECT_GODOT.exists():
        print(f"❌ project.godot not found at {PROJECT_GODOT}")
        return ProjectSpec()
    
    content = PROJECT_GODOT.read_text(encoding="utf-8")
    spec = ProjectSpec()
    
    # Parse physics FPS
    fps_match = re.search(r'common/physics_ticks_per_second=(\d+)', content)
    if fps_match:
        spec.physics_fps = int(fps_match.group(1))
    
    # Parse viewport size
    width_match = re.search(r'window/size/viewport_width=(\d+)', content)
    if width_match:
        spec.viewport_width = int(width_match.group(1))
    
    height_match = re.search(r'window/size/viewport_height=(\d+)', content)
    if height_match:
        spec.viewport_height = int(height_match.group(1))
    
    # Count button inputs per player
    # P1 buttons: p1_light_punch, p1_medium_punch, p1_heavy_punch, p1_light_kick, p1_medium_kick, p1_heavy_kick
    p1_buttons = re.findall(r'p1_(light|medium|heavy)_(punch|kick)=\{', content)
    spec.button_count_p1 = len(p1_buttons)
    
    p2_buttons = re.findall(r'p2_(light|medium|heavy)_(punch|kick)=\{', content)
    spec.button_count_p2 = len(p2_buttons)
    
    # Parse collision layers
    layer_matches = re.findall(r'2d_physics/layer_\d+="([^"]+)"', content)
    spec.collision_layers = layer_matches
    
    # Parse autoloads
    autoload_matches = re.findall(r'^(\w+)="\*res://', content, re.MULTILINE)
    spec.autoloads = autoload_matches
    
    print(f"✅ Project parsed: {spec.physics_fps}fps, {spec.button_count_p1} buttons/player")
    return spec

def compare_specs(gdd: GDDSpec, project: ProjectSpec) -> List[Dict[str, Any]]:
    """Compare GDD against implementation and generate report"""
    results = []
    
    def add_result(category: str, spec_name: str, expected: Any, actual: Any, passed: bool):
        results.append({
            "category": category,
            "spec": spec_name,
            "expected": expected,
            "actual": actual,
            "passed": passed
        })
    
    # Physics FPS
    add_result(
        "Core",
        "Physics FPS",
        gdd.physics_fps,
        project.physics_fps,
        project.physics_fps == gdd.physics_fps
    )
    
    # Button count
    expected_buttons = gdd.button_count
    add_result(
        "Input",
        "P1 Button Count",
        expected_buttons,
        project.button_count_p1,
        project.button_count_p1 == expected_buttons
    )
    
    add_result(
        "Input",
        "P2 Button Count",
        expected_buttons,
        project.button_count_p2,
        project.button_count_p2 == expected_buttons
    )
    
    # Collision layers
    missing_layers = set(gdd.collision_layers) - set(project.collision_layers)
    extra_layers = set(project.collision_layers) - set(gdd.collision_layers)
    layers_match = len(missing_layers) == 0 and len(extra_layers) == 0
    
    add_result(
        "Physics",
        "Collision Layers",
        f"{len(gdd.collision_layers)} layers: {', '.join(gdd.collision_layers)}",
        f"{len(project.collision_layers)} layers: {', '.join(project.collision_layers)}",
        layers_match
    )
    
    if missing_layers:
        add_result(
            "Physics",
            "Missing Layers",
            "",
            f"Missing: {', '.join(missing_layers)}",
            False
        )
    
    if extra_layers:
        add_result(
            "Physics",
            "Extra Layers",
            "",
            f"Extra: {', '.join(extra_layers)}",
            True  # Not necessarily bad
        )
    
    # Autoloads
    missing_autoloads = set(gdd.required_autoloads) - set(project.autoloads)
    extra_autoloads = set(project.autoloads) - set(gdd.required_autoloads)
    autoloads_match = len(missing_autoloads) == 0
    
    add_result(
        "Systems",
        "Required Autoloads",
        f"{len(gdd.required_autoloads)} systems",
        f"{len(project.autoloads)} systems",
        autoloads_match
    )
    
    if missing_autoloads:
        add_result(
            "Systems",
            "Missing Autoloads",
            "",
            f"Missing: {', '.join(missing_autoloads)}",
            False
        )
    
    return results

def print_report(results: List[Dict[str, Any]]):
    """Print formatted comparison report"""
    print("\n" + "="*80)
    print("📊 GDD COMPLIANCE REPORT")
    print("="*80)
    
    passed_count = sum(1 for r in results if r["passed"])
    total_count = len(results)
    
    # Group by category
    by_category = {}
    for result in results:
        cat = result["category"]
        if cat not in by_category:
            by_category[cat] = []
        by_category[cat].append(result)
    
    # Print each category
    for category, items in by_category.items():
        print(f"\n📁 {category}")
        print("-" * 80)
        
        for item in items:
            status = "✅" if item["passed"] else "❌"
            print(f"{status} {item['spec']}")
            
            if item["expected"]:
                print(f"   Expected: {item['expected']}")
            if item["actual"]:
                print(f"   Actual:   {item['actual']}")
    
    # Summary
    print("\n" + "="*80)
    print(f"📈 SUMMARY: {passed_count}/{total_count} checks passed ({passed_count*100//total_count}%)")
    print("="*80)
    
    if passed_count == total_count:
        print("🎉 All checks passed! Implementation matches GDD.")
        return 0
    else:
        print("⚠️  Some deviations found. Review discrepancies above.")
        return 1

def main():
    print("🔧 Tool 10: GDD Diff Reporter")
    print("Comparing GDD specs vs. implementation...\n")
    
    gdd_spec = parse_gdd()
    project_spec = parse_project_godot()
    
    results = compare_specs(gdd_spec, project_spec)
    exit_code = print_report(results)
    
    print("\n💡 TIP: Update GDD or implementation to resolve discrepancies.")
    print("📖 GDD: games/ashfall/docs/GDD.md")
    print("⚙️  Project: games/ashfall/project.godot")
    
    return exit_code

if __name__ == "__main__":
    sys.exit(main())
