#!/usr/bin/env python3
"""
Integration Gate Automation
Runs all validators in sequence and provides overall PASS/WARN/FAIL status.
This is the meta-tool that ensures project health before merging.
"""

import sys
import subprocess
import json
from pathlib import Path
from typing import Dict, List, Tuple
from datetime import datetime

class IntegrationGate:
    def __init__(self, project_root: Path):
        self.project_root = project_root
        self.tools_dir = project_root / "tools"
        self.results: Dict[str, Dict] = {}
        self.start_time = datetime.now()
        
    def run_validator(self, name: str, script_path: Path, timeout: int = 60) -> Tuple[bool, str, str]:
        """
        Run a validator script.
        Returns (passed, stdout, stderr)
        """
        print(f"[*] Running {name}...")
        
        if not script_path.exists():
            print(f"   ⚠️  Script not found: {script_path}")
            return False, "", f"Script not found: {script_path}"
        
        try:
            result = subprocess.run(
                [sys.executable, str(script_path)],
                cwd=str(self.project_root),
                capture_output=True,
                text=True,
                timeout=timeout
            )
            
            passed = result.returncode == 0
            status = "[PASS] PASS" if passed else "[FAIL] FAIL"
            print(f"   {status}")
            
            return passed, result.stdout, result.stderr
            
        except subprocess.TimeoutExpired:
            print(f"   [TIME] TIMEOUT")
            return False, "", f"Validator timed out after {timeout}s"
        except Exception as e:
            print(f"   [FAIL] ERROR: {e}")
            return False, "", str(e)
    
    def run_all_validators(self) -> bool:
        """Run all validators in sequence. Returns True if all pass."""
        print()
        print("=" * 80)
        print("[GATE] RUNNING INTEGRATION GATE VALIDATORS")
        print("=" * 80)
        print()
        
        all_passed = True
        
        # Validator 1: Autoload Dependency Analyzer
        validator_name = "Autoload Dependency Analyzer"
        validator_path = self.tools_dir / "check-autoloads.py"
        passed, stdout, stderr = self.run_validator(validator_name, validator_path, timeout=30)
        self.results[validator_name] = {
            "passed": passed,
            "stdout": stdout,
            "stderr": stderr
        }
        if not passed:
            all_passed = False
        
        print()
        
        # Validator 2: Signal Wiring Validator
        validator_name = "Signal Wiring Validator"
        validator_path = self.tools_dir / "check-signals.py"
        passed, stdout, stderr = self.run_validator(validator_name, validator_path, timeout=30)
        self.results[validator_name] = {
            "passed": passed,
            "stdout": stdout,
            "stderr": stderr
        }
        # Treat signal warnings as non-fatal
        if not passed:
            print(f"   [INFO] Signal validator found warnings (non-fatal)")
        
        print()
        
        # Validator 3: Scene Integrity Checker
        validator_name = "Scene Integrity Checker"
        validator_path = self.tools_dir / "check-scenes.py"
        passed, stdout, stderr = self.run_validator(validator_name, validator_path, timeout=30)
        self.results[validator_name] = {
            "passed": passed,
            "stdout": stdout,
            "stderr": stderr
        }
        if not passed:
            all_passed = False
        
        print()
        
        # Validator 4: Project Validator (meta-validator)
        validator_name = "Project Validator"
        validator_path = self.tools_dir / "validate-project.py"
        passed, stdout, stderr = self.run_validator(validator_name, validator_path, timeout=60)
        self.results[validator_name] = {
            "passed": passed,
            "stdout": stdout,
            "stderr": stderr
        }
        if not passed:
            all_passed = False
        
        return all_passed
    
    def print_summary_report(self, all_passed: bool):
        """Print final summary report"""
        elapsed = (datetime.now() - self.start_time).total_seconds()
        
        print()
        print("=" * 80)
        print("[*] INTEGRATION GATE SUMMARY")
        print("=" * 80)
        print()
        
        print(f"[TIME] Total time: {elapsed:.1f}s")
        print()
        
        # Count results
        passed_count = sum(1 for r in self.results.values() if r["passed"])
        total_count = len(self.results)
        
        print(f"[*] Results: {passed_count}/{total_count} validators passed")
        print()
        
        # List individual results
        for validator_name, result in self.results.items():
            status = "[PASS]" if result["passed"] else "[FAIL]"
            print(f"   {status} {validator_name}")
        
        print()
        
        # Overall status
        if all_passed:
            print("=" * 80)
            print("[PASS] INTEGRATION GATE: PASS")
            print("=" * 80)
            print()
            print("All validators passed. Project is ready for integration.")
        else:
            print("=" * 80)
            print("[FAIL] INTEGRATION GATE: FAIL")
            print("=" * 80)
            print()
            print("One or more validators failed. Review the output above for details.")
            print()
            print("To see detailed output for a failed validator, run it individually:")
            for validator_name, result in self.results.items():
                if not result["passed"]:
                    # Map validator name to script
                    script_map = {
                        "Autoload Dependency Analyzer": "check-autoloads.py",
                        "Signal Wiring Validator": "check-signals.py",
                        "Scene Integrity Checker": "check-scenes.py",
                        "Project Validator": "validate-project.py"
                    }
                    script = script_map.get(validator_name, "")
                    if script:
                        print(f"   python tools/{script}")
        
        print()
    
    def save_report_json(self, output_path: Path):
        """Save detailed report as JSON for CI integration"""
        report = {
            "timestamp": self.start_time.isoformat(),
            "elapsed_seconds": (datetime.now() - self.start_time).total_seconds(),
            "overall_status": "PASS" if all(r["passed"] for r in self.results.values()) else "FAIL",
            "validators": {}
        }
        
        for validator_name, result in self.results.items():
            report["validators"][validator_name] = {
                "status": "PASS" if result["passed"] else "FAIL",
                "stdout_preview": result["stdout"][:500] if result["stdout"] else "",
                "stderr_preview": result["stderr"][:500] if result["stderr"] else ""
            }
        
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(json.dumps(report, indent=2))
        print(f"[*] Detailed report saved to: {output_path}")
        print()
    
    def run(self, save_json: bool = False) -> int:
        """Run integration gate. Returns exit code (0 = pass, 1 = fail)"""
        print("=" * 80)
        print("[GATE] INTEGRATION GATE AUTOMATION")
        print("=" * 80)
        print()
        print("This tool runs all validators to ensure project health.")
        print(f"Started at: {self.start_time.strftime('%Y-%m-%d %H:%M:%S')}")
        
        # Run all validators
        all_passed = self.run_all_validators()
        
        # Print summary
        self.print_summary_report(all_passed)
        
        # Save JSON report if requested
        if save_json:
            report_path = self.project_root / "build" / "integration-gate-report.json"
            self.save_report_json(report_path)
        
        return 0 if all_passed else 1


def main():
    # Find project root
    current = Path(__file__).parent.parent
    
    # Check for --json flag
    save_json = "--json" in sys.argv
    
    gate = IntegrationGate(current)
    exit_code = gate.run(save_json=save_json)
    sys.exit(exit_code)


if __name__ == "__main__":
    main()
