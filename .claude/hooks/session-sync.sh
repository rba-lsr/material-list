#!/bin/bash
# Session-start sync (Matt + Peter). Runs automatically when a Claude Code
# session opens in this repo (see .claude/settings.json), so nobody has to
# remember to ask for a pull.
#
#   - Up to date with GitHub        -> says so.
#   - Behind, nothing local at risk -> pulls, and lists what came in.
#   - Behind, with local work       -> does NOT pull; tells Claude to stop and ask.
#
# It only ever fast-forwards. It never merges, resets, stashes or pushes.
# The same file is in every RBA repo; the master copy is in rba-command-center.
# Usage: session-sync.sh [repo-folder]   (default: the session's project folder)

export GIT_TERMINAL_PROMPT=0
dir="${1:-${CLAUDE_PROJECT_DIR:-.}}"
cd "$dir" 2>/dev/null || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

name=$(basename "$(git rev-parse --show-toplevel)")
branch=$(git branch --show-current)
tag="[session-sync] $name"

if ! git fetch --quiet 2>/dev/null; then
  echo "$tag: could not reach GitHub (offline, or not signed in). This copy may be out of date. Tell the user before changing files."
  exit 0
fi
if ! git rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1; then
  echo "$tag: branch '$branch' is not linked to GitHub, so there is nothing to compare against. Tell the user."
  exit 0
fi

behind=$(git rev-list --count 'HEAD..@{u}')
ahead=$(git rev-list --count '@{u}..HEAD')
dirty=$(git status --porcelain --untracked-files=no | wc -l | tr -d ' ')

local_note=""
[ "$ahead" -gt 0 ] && local_note="$local_note $ahead local commit(s) not pushed yet."
[ "$dirty" -gt 0 ] && local_note="$local_note $dirty file(s) changed but not committed."
[ "$branch" != "main" ] && local_note="$local_note On branch '$branch', not main."

if [ "$behind" -eq 0 ]; then
  echo "$tag: up to date with GitHub.$local_note"
  exit 0
fi

incoming=$(git log 'HEAD..@{u}' --format='  - %an, %ad: %s' --date=format:'%b %d %H:%M')
files=$(git diff --name-only 'HEAD...@{u}')

if [ "$ahead" -gt 0 ] || [ "$dirty" -gt 0 ]; then
  echo "$tag: STOP. GitHub has $behind new commit(s) and this copy also has local work, so nothing was pulled.$local_note"
  echo "$incoming"
  echo "Before changing any file, tell the user this in plain English and ask how to proceed."
  exit 0
fi

if ! git pull --ff-only --quiet 2>/dev/null; then
  echo "$tag: STOP. GitHub has $behind new commit(s) but the pull failed, so this copy is still out of date."
  echo "$incoming"
  echo "Tell the user before changing any file."
  exit 0
fi

echo "$tag: pulled $behind new commit(s) from GitHub. This copy is now up to date."
echo "$incoming"
if echo "$files" | grep -q '^supabase/migrations/'; then
  echo "New database migration file(s) came in:"
  echo "$files" | grep '^supabase/migrations/' | sed 's/^/  - /'
  echo "A migration file in the repo is not proof it was applied to the live database. Check before relying on it."
fi
if echo "$files" | grep -q -E '(^|/)package(-lock)?\.json$'; then
  echo "Dependencies changed: run npm install before running the app."
fi
echo "Tell the user what came in before doing anything else."
exit 0
