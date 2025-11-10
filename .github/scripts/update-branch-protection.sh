#!/usr/bin/env bash
set -euo pipefail

# Update branch protection rules for main branch
# Requires: gh CLI installed and authenticated

REPO="${GITHUB_REPOSITORY:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"
BRANCH="main"

echo "Updating branch protection rules for ${REPO}:${BRANCH}"

# Create JSON payload for branch protection
cat >/tmp/branch-protection.json <<'EOF'
{
  "required_status_checks": {
    "strict": true,
    "checks": [
      {"context": "buildbot/nix-eval"}
      {"context": "buildbot/nix-build"},
      {"context": "buildbot/nix-effects"}
    ]
  },
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": false,
    "require_code_owner_reviews": false,
    "required_approving_review_count": 0
  },
  "enforce_admins": false,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "required_conversation_resolution": false,
  "lock_branch": false,
  "allow_fork_syncing": false,
  "restrictions": null
}
EOF

echo "Updating branch protection rules..."
gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "/repos/${REPO}/branches/${BRANCH}/protection" \
  --input /tmp/branch-protection.json

rm /tmp/branch-protection.json

echo ""
echo "✅ Branch protection rules updated successfully!"
echo ""
echo "Required status checks are now:"
echo "  - buildbot/nix-build"
echo "  - buildbot/nix-eval"
echo "  - buildbot/nix-effects"
