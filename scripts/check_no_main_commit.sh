#!/usr/bin/env bash
set -euo pipefail

branch="$(git symbolic-ref --short HEAD 2>/dev/null || echo "")"

if [[ "$branch" == "main" || "$branch" == "master" ]]; then
    echo "Direct commits to '$branch' are not allowed. Create a feature branch and open a PR." >&2
    exit 1
fi
