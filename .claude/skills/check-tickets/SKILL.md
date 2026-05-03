---
name: check-tickets
description: "Check status of my GitHub issues and PRs. Use when user says 'check tickets', 'check state ticket', 'ticket status', or similar."
argument-hint: "[--me | --all | username]"
---

# Check Ticket Status

Check the status of GitHub issues and pull requests for the current repository.

## Arguments
- No args or `--me`: Show tickets assigned to / authored by the current user
- `--all`: Show all open tickets in the repo
- `username`: Show tickets for a specific GitHub user

<args>$ARGUMENTS</args>

## Process

1. **Determine scope** from arguments (default: current user `@me`)

2. **Fetch GitHub Issues** assigned to the target user:
   ```bash
   gh issue list --assignee <user> --state all --limit 20
   ```

3. **Fetch Pull Requests** authored by the target user:
   ```bash
   gh pr list --author <user> --state all --limit 20
   ```

4. **For each OPEN PR**, fetch detailed status:
   ```bash
   gh pr view <number> --json title,state,reviews,mergeable,statusCheckRollup
   ```
   Extract: CI status, review state, merge conflicts

5. **Present results** in a concise markdown table:

   | # | Feature | Issue | PR | CI | Review | Merge Status |
   |---|---------|-------|----|----|--------|--------------|

   Then a **summary** section highlighting:
   - Which PRs are ready to merge
   - Which PRs have conflicts that need resolving
   - Which PRs are waiting for review
   - Any failed CI checks

## Important
- Use `gh` CLI exclusively (not GitHub API calls)
- Keep output concise - table + summary only
- If `--all` flag, skip the `--assignee`/`--author` filter
