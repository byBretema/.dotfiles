#!/usr/bin/env bash
# Usage: git-path-search.sh PANE_ID PANE_PATH
# Copy-mode search over the paths in `git status`.

pane="$1"
cd "$2" 2>/dev/null || exit 0

# Renames show as "old -> new"; keep the new path. Escape ERE metachars so paths match literally.
re=$(git status --porcelain 2>/dev/null | cut -c4- | sed -E 's/.* -> //; s/^"(.*)"$/\1/; s/[][\.*^$+?(){}|]/\\&/g' | paste -sd'|')

[[ -z "$re" ]] && { tmux display-message "No git changes"; exit 0; }
tmux copy-mode -t "$pane" \; send-keys -t "$pane" -X search-backward "$re"
