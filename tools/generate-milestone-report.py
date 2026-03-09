#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
"""
Tool: Milestone Report Generator
Automates Dev Diary drafts and wiki update suggestions after each milestone.
Collects merged PRs, closed issues, commits, and contributors from git/gh CLI.
Author: Jango (Lead, Tool Engineer)
"""

import argparse
import json
import subprocess
import re
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple


# ── Git / GitHub CLI helpers ────────────────────────────────────────────────

def run_cmd(cmd: List[str], cwd: Optional[str] = None) -> Tuple[int, str]:
    """Run a command and return (returncode, stdout)."""
    try:
        result = subprocess.run(
            cmd, capture_output=True, text=True, encoding="utf-8",
            errors="replace", cwd=cwd,
        )
        return result.returncode, result.stdout.strip()
    except FileNotFoundError:
        return 1, f"Command not found: {cmd[0]}"


def get_merged_prs(since: str) -> List[Dict]:
    """Fetch merged PRs since a date via gh CLI."""
    cmd = [
        "gh", "pr", "list", "--state", "merged",
        "--json", "number,title,author,mergedAt,labels",
        "--limit", "50",
        "--search", f"merged:>={since}",
    ]
    rc, out = run_cmd(cmd)
    if rc != 0 or not out:
        return []
    try:
        return json.loads(out)
    except json.JSONDecodeError:
        return []


def get_closed_issues(since: str) -> List[Dict]:
    """Fetch closed issues since a date via gh CLI."""
    cmd = [
        "gh", "issue", "list", "--state", "closed",
        "--json", "number,title,labels,closedAt",
        "--limit", "50",
        "--search", f"closed:>={since}",
    ]
    rc, out = run_cmd(cmd)
    if rc != 0 or not out:
        return []
    try:
        return json.loads(out)
    except json.JSONDecodeError:
        return []


def get_commits_since(since: str, since_tag: Optional[str] = None) -> List[str]:
    """Return list of one-line commit summaries since a date or tag."""
    if since_tag:
        cmd = ["git", "log", f"{since_tag}..HEAD", "--oneline"]
    else:
        cmd = ["git", "log", f"--since={since}", "--oneline"]
    rc, out = run_cmd(cmd)
    if rc != 0 or not out:
        return []
    return out.splitlines()


def get_contributors(since: str, since_tag: Optional[str] = None) -> List[str]:
    """Return unique contributor names from git log."""
    if since_tag:
        cmd = ["git", "log", f"{since_tag}..HEAD", "--format=%aN"]
    else:
        cmd = ["git", "log", f"--since={since}", "--format=%aN"]
    rc, out = run_cmd(cmd)
    if rc != 0 or not out:
        return []
    names = sorted(set(out.splitlines()))
    return names


def get_changed_paths(since: str, since_tag: Optional[str] = None) -> List[str]:
    """Return list of file paths changed in commits since date/tag."""
    if since_tag:
        cmd = ["git", "diff", "--name-only", f"{since_tag}..HEAD"]
    else:
        cmd = ["git", "log", f"--since={since}", "--name-only", "--pretty=format:"]
    rc, out = run_cmd(cmd)
    if rc != 0 or not out:
        return []
    return sorted(set(line for line in out.splitlines() if line.strip()))


def resolve_tag_date(tag: str) -> Optional[str]:
    """Get the ISO date of a git tag."""
    rc, out = run_cmd(["git", "log", "-1", "--format=%aI", tag])
    if rc != 0 or not out:
        return None
    return out[:10]  # YYYY-MM-DD


# ── Wiki page suggestion engine ────────────────────────────────────────────

WIKI_PAGE_RULES: Dict[str, List[str]] = {
    "Architecture": [
        "scripts/systems/", "scripts/core/", "scripts/managers/",
        "scenes/", "project.godot", "autoloads",
    ],
    "Roadmap": [
        ".github/", "docs/", "CONTRIBUTING", "README",
        "milestone", "roadmap",
    ],
    "GDD": [
        "docs/gdd", "docs/design", "scripts/fighters/",
        "scripts/combat/", "resources/fighters/",
    ],
    "Home": [
        "README.md", "docs/GETTING_STARTED",
    ],
    "Team": [
        "CODEOWNERS", ".squad/", "squad.config",
        "CONTRIBUTING",
    ],
    "_Sidebar": [
        "docs/", "tools/", "README.md",
    ],
}


def suggest_wiki_updates(
    changed_paths: List[str], merged_prs: List[Dict]
) -> Dict[str, List[str]]:
    """Map changed paths and PR labels to wiki pages that likely need updates."""
    suggestions: Dict[str, List[str]] = {}

    for page, patterns in WIKI_PAGE_RULES.items():
        reasons: List[str] = []
        for path in changed_paths:
            path_lower = path.lower().replace("\\", "/")
            for pattern in patterns:
                if pattern.lower() in path_lower:
                    reasons.append(f"File changed: {path}")
                    break
        # Also check PR labels
        for pr in merged_prs:
            labels = [lb.get("name", "") for lb in pr.get("labels", [])]
            for label in labels:
                label_lower = label.lower()
                if page.lower() in label_lower or any(
                    p.rstrip("/").lower() in label_lower for p in patterns
                ):
                    reasons.append(
                        f"PR #{pr['number']} label: {label}"
                    )
        if reasons:
            # Deduplicate but keep order
            seen = set()
            unique: List[str] = []
            for r in reasons:
                if r not in seen:
                    seen.add(r)
                    unique.append(r)
            suggestions[page] = unique[:8]  # cap reasons per page

    return suggestions


# ── Report generators ───────────────────────────────────────────────────────

def build_dev_diary(
    milestone: str,
    diary_number: int,
    merged_prs: List[Dict],
    closed_issues: List[Dict],
    commits: List[str],
    contributors: List[str],
) -> str:
    """Generate a Dev Diary markdown post."""
    today = datetime.now().strftime("%Y-%m-%d")
    lines: List[str] = []

    lines.append(f"# Dev Diary #{diary_number} — {milestone}")
    lines.append(f"*Published {today}*\n")

    # What We Built
    lines.append("## 🔨 What We Built\n")
    if merged_prs:
        for pr in merged_prs:
            author = pr.get("author", {}).get("login", "unknown")
            lines.append(f"- **#{pr['number']}** {pr['title']} (@{author})")
    else:
        lines.append("- *(no merged PRs found in this window)*")
    lines.append("")

    # Key Decisions
    lines.append("## 🧭 Key Decisions\n")
    lines.append("<!-- Fill in key architectural or design decisions made this milestone -->")
    lines.append("- TODO: Add key decisions\n")

    # Stats
    lines.append("## 📊 Stats\n")
    lines.append(f"| Metric | Count |")
    lines.append(f"|--------|-------|")
    lines.append(f"| PRs Merged | {len(merged_prs)} |")
    lines.append(f"| Issues Closed | {len(closed_issues)} |")
    lines.append(f"| Commits | {len(commits)} |")
    lines.append(f"| Contributors | {len(contributors)} |")
    lines.append("")

    if contributors:
        lines.append("**Contributors:** " + ", ".join(contributors))
        lines.append("")

    # Closed issues summary
    if closed_issues:
        lines.append("### Issues Closed\n")
        for issue in closed_issues:
            labels = ", ".join(
                lb.get("name", "") for lb in issue.get("labels", [])
            )
            label_str = f" `[{labels}]`" if labels else ""
            lines.append(f"- #{issue['number']} {issue['title']}{label_str}")
        lines.append("")

    # What's Next
    lines.append("## 🔜 What's Next\n")
    lines.append("<!-- Fill in goals for the next milestone -->")
    lines.append("- TODO: Add next milestone goals\n")

    lines.append("---")
    lines.append("*Generated by `tools/generate-milestone-report.py`*")

    return "\n".join(lines)


def build_wiki_checklist(suggestions: Dict[str, List[str]]) -> str:
    """Generate a markdown checklist of suggested wiki updates."""
    lines: List[str] = []
    lines.append("# 📝 Wiki Update Checklist\n")

    if not suggestions:
        lines.append("No wiki updates suggested — no relevant file changes detected.")
        return "\n".join(lines)

    for page, reasons in sorted(suggestions.items()):
        lines.append(f"## [ ] Update **{page}** wiki page\n")
        for reason in reasons:
            lines.append(f"  - {reason}")
        lines.append("")

    lines.append("---")
    lines.append("*Generated by `tools/generate-milestone-report.py`*")
    return "\n".join(lines)


# ── CLI entry point ─────────────────────────────────────────────────────────

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate milestone Dev Diary draft and wiki update suggestions.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""Examples:
  python tools/generate-milestone-report.py --milestone "M2" --since "2026-03-01"
  python tools/generate-milestone-report.py --milestone "M3" --since-tag "v0.2.0"
  python tools/generate-milestone-report.py --milestone "M2" --since "2026-03-01" --diary-number 2 --out report.md
        """,
    )
    parser.add_argument(
        "--milestone", required=True,
        help="Milestone name, e.g. 'M2' or 'Alpha Sprint 3'",
    )
    parser.add_argument(
        "--since", default=None,
        help="Collect data since this date (YYYY-MM-DD)",
    )
    parser.add_argument(
        "--since-tag", default=None,
        help="Collect data since this git tag (e.g. v0.2.0)",
    )
    parser.add_argument(
        "--diary-number", type=int, default=1,
        help="Dev Diary issue number (default: 1)",
    )
    parser.add_argument(
        "--out", default=None,
        help="Write report to a file instead of stdout",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    if not args.since and not args.since_tag:
        print("❌ Error: Provide --since DATE or --since-tag TAG")
        sys.exit(1)

    # Resolve the effective date for gh queries
    if args.since_tag:
        tag_date = resolve_tag_date(args.since_tag)
        if not tag_date:
            print(f"⚠️  Warning: Could not resolve date for tag '{args.since_tag}', using 30 days ago")
            tag_date = datetime.now().strftime("%Y-%m-%d")
        since_date = tag_date
    else:
        since_date = args.since

    print(f"🔍 Collecting data for milestone: {args.milestone}")
    print(f"   Since: {since_date}" + (f" (tag: {args.since_tag})" if args.since_tag else ""))
    print()

    # Collect data
    print("📥 Fetching merged PRs…")
    merged_prs = get_merged_prs(since_date)
    print(f"   Found {len(merged_prs)} merged PRs")

    print("📥 Fetching closed issues…")
    closed_issues = get_closed_issues(since_date)
    print(f"   Found {len(closed_issues)} closed issues")

    print("📥 Counting commits…")
    commits = get_commits_since(since_date, args.since_tag)
    print(f"   Found {len(commits)} commits")

    print("📥 Getting contributors…")
    contributors = get_contributors(since_date, args.since_tag)
    print(f"   Found {len(contributors)} contributors: {', '.join(contributors) if contributors else 'none'}")

    print("📥 Getting changed file paths…")
    changed_paths = get_changed_paths(since_date, args.since_tag)
    print(f"   Found {len(changed_paths)} changed files")
    print()

    # Generate Dev Diary
    diary = build_dev_diary(
        milestone=args.milestone,
        diary_number=args.diary_number,
        merged_prs=merged_prs,
        closed_issues=closed_issues,
        commits=commits,
        contributors=contributors,
    )

    # Generate wiki suggestions
    suggestions = suggest_wiki_updates(changed_paths, merged_prs)
    checklist = build_wiki_checklist(suggestions)

    # Combine output
    full_report = diary + "\n\n" + checklist

    if args.out:
        out_path = Path(args.out)
        out_path.write_text(full_report, encoding="utf-8")
        print(f"✅ Report written to {out_path}")
    else:
        print("=" * 70)
        print(full_report)
        print("=" * 70)

    # Summary
    print()
    print(f"✅ Milestone report for '{args.milestone}' complete!")
    print(f"   📝 Dev Diary #{args.diary_number} — {len(merged_prs)} PRs, {len(closed_issues)} issues, {len(commits)} commits")
    if suggestions:
        print(f"   📋 Wiki pages to update: {', '.join(sorted(suggestions.keys()))}")
    else:
        print("   📋 No wiki updates suggested")


if __name__ == "__main__":
    main()
