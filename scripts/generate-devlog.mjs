#!/usr/bin/env node

/**
 * Devlog Generator Script
 * 
 * Aggregates activity from constellation repos (Syntax-Sorcery, FFS, flora, ComeRosquillas, ffs-squad-monitor)
 * Sources: Closed issues (24h), merged PRs (24h), GitHub Pages deploys, decisions.md changes
 * Output: src/data/devlog.json
 */

import { exec } from 'child_process';
import { promisify } from 'util';
import { readFileSync, writeFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const execAsync = promisify(exec);
const __dirname = dirname(fileURLToPath(import.meta.url));
const DEVLOG_PATH = join(__dirname, '../src/data/devlog.json');

// Constellation repos to monitor
const REPOS = [
  { owner: 'jperezdelreal', name: 'Syntax-Sorcery', displayName: 'Syntax-Sorcery' },
  { owner: 'jperezdelreal', name: 'FirstFrameStudios', displayName: 'FirstFrameStudios' },
  { owner: 'jperezdelreal', name: 'flora', displayName: 'flora' },
  { owner: 'jperezdelreal', name: 'ComeRosquillas', displayName: 'ComeRosquillas' },
  { owner: 'jperezdelreal', name: 'ffs-squad-monitor', displayName: 'ffs-squad-monitor' },
];

// Calculate day number from project start (March 16, 2026)
const PROJECT_START = new Date('2026-03-16');
function getDayNumber(date = new Date()) {
  const diff = date.getTime() - PROJECT_START.getTime();
  return Math.floor(diff / (1000 * 60 * 60 * 24)) + 1;
}

async function ghQuery(query) {
  try {
    const { stdout } = await execAsync(`gh api graphql -f query="${query.replace(/"/g, '\\"')}"`);
    return JSON.parse(stdout);
  } catch (error) {
    console.error('GitHub API query failed:', error.message);
    return null;
  }
}

async function fetchClosedIssues(owner, name) {
  const since = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();
  const query = `
    query {
      repository(owner: "${owner}", name: "${name}") {
        issues(first: 20, states: CLOSED, orderBy: {field: UPDATED_AT, direction: DESC}, filterBy: {since: "${since}"}) {
          nodes {
            number
            title
            url
            closedAt
          }
        }
      }
    }
  `;
  
  const result = await ghQuery(query);
  if (!result?.data?.repository?.issues?.nodes) return [];
  
  return result.data.repository.issues.nodes
    .filter(issue => new Date(issue.closedAt) > new Date(since))
    .map(issue => ({
      type: 'issue',
      title: `Closed issue #${issue.number}: ${issue.title}`,
      url: issue.url,
    }));
}

async function fetchMergedPRs(owner, name) {
  const since = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();
  const query = `
    query {
      repository(owner: "${owner}", name: "${name}") {
        pullRequests(first: 20, states: MERGED, orderBy: {field: UPDATED_AT, direction: DESC}, baseRefName: "main") {
          nodes {
            number
            title
            url
            mergedAt
          }
        }
      }
    }
  `;
  
  const result = await ghQuery(query);
  if (!result?.data?.repository?.pullRequests?.nodes) return [];
  
  return result.data.repository.pullRequests.nodes
    .filter(pr => new Date(pr.mergedAt) > new Date(since))
    .map(pr => ({
      type: 'pr',
      title: `Merged PR #${pr.number}: ${pr.title}`,
      url: pr.url,
    }));
}

async function fetchDeployments(owner, name) {
  const since = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();
  
  try {
    const { stdout } = await execAsync(
      `gh api repos/${owner}/${name}/deployments --method GET -f environment=github-pages -f per_page=10`
    );
    const deployments = JSON.parse(stdout);
    
    return deployments
      .filter(d => new Date(d.created_at) > new Date(since))
      .map(d => ({
        type: 'deploy',
        title: `Deployed to GitHub Pages`,
        url: d.url,
      }));
  } catch (error) {
    return [];
  }
}

async function fetchDecisionChanges(owner, name) {
  const since = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();
  
  try {
    // Check for commits to .squad/decisions.md in last 24h
    const { stdout } = await execAsync(
      `gh api repos/${owner}/${name}/commits --method GET -f path=.squad/decisions.md -f since=${since} -f per_page=10`
    );
    const commits = JSON.parse(stdout);
    
    return commits.map(c => ({
      type: 'decision',
      title: `Decision updated: ${c.commit.message.split('\n')[0]}`,
      url: c.html_url,
    }));
  } catch (error) {
    return [];
  }
}

async function generateDevlogEntry() {
  console.log('🔍 Fetching activity from constellation repos...');
  
  const today = new Date().toISOString().split('T')[0];
  const events = [];

  for (const repo of REPOS) {
    console.log(`  Checking ${repo.displayName}...`);
    
    const [issues, prs, deploys, decisions] = await Promise.all([
      fetchClosedIssues(repo.owner, repo.name),
      fetchMergedPRs(repo.owner, repo.name),
      fetchDeployments(repo.owner, repo.name),
      fetchDecisionChanges(repo.owner, repo.name),
    ]);

    const repoEvents = [...issues, ...prs, ...deploys, ...decisions].map(e => ({
      ...e,
      repo: repo.displayName,
    }));
    
    events.push(...repoEvents);
    console.log(`    Found ${repoEvents.length} events`);
  }

  return {
    date: today,
    dayNumber: getDayNumber(),
    events,
  };
}

async function main() {
  console.log('📝 Starting devlog generation...\n');

  // Load existing devlog
  let devlog = [];
  try {
    devlog = JSON.parse(readFileSync(DEVLOG_PATH, 'utf-8'));
  } catch (error) {
    console.log('No existing devlog found, starting fresh.');
  }

  // Generate today's entry
  const newEntry = await generateDevlogEntry();
  
  console.log(`\n✅ Generated entry for ${newEntry.date} with ${newEntry.events.length} events`);

  // Check if entry for today already exists
  const today = newEntry.date;
  const existingIndex = devlog.findIndex(e => e.date === today);
  
  if (existingIndex >= 0) {
    console.log('   Replacing existing entry for today');
    devlog[existingIndex] = newEntry;
  } else {
    console.log('   Adding new entry');
    devlog.unshift(newEntry); // Add to beginning (newest first)
  }

  // Keep only last 90 days
  devlog = devlog.slice(0, 90);

  // Write back
  writeFileSync(DEVLOG_PATH, JSON.stringify(devlog, null, 2));
  console.log(`\n💾 Devlog saved to ${DEVLOG_PATH}`);
  console.log(`   Total entries: ${devlog.length}`);
}

main().catch(error => {
  console.error('❌ Devlog generation failed:', error);
  process.exit(1);
});
