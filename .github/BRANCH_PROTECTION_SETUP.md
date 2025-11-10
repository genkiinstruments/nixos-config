# Branch Protection Setup Instructions

After merging these changes, you need to update your existing branch protection
rules in GitHub.

## Steps to Update Branch Protection

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Branches**
3. **Edit** the existing rule for `main`
4. Scroll to **Require status checks to pass before merging**

### Update Required Status Checks

In the "Status checks that are required" section:

**Required status checks (configured via script):**

- ✅ `buildbot/nix-eval` (evaluates flake and checks for errors)
- ✅ `buildbot/nix-build` (builds all NixOS configurations)
- ✅ `buildbot/nix-effects` (run all deployments and such)

**To update programmatically, run:**

```bash
./.github/scripts/update-branch-protection.sh
```

This script sets the required checks to only the buildbot checks, which already
provide comprehensive CI validation including builds and evaluations.

## How It Works

1. The `update-flake-lock.yml` and `update-lazy-plugins.yaml` workflows create
   PRs with the `auto-merge` label
2. Buildbot runs `nix-eval`, `nix-build` and `nix-effects` checks on all PRs
3. The `auto-merge.yaml` workflow enables GitHub's auto-merge feature
4. GitHub will **only merge the PR** once all required buildbot checks pass
5. If checks fail, the PR stays open until the issues are fixed

## Verifying the Setup

After configuration:

- Create a test PR with the `auto-merge` label
- Verify that it waits for CI checks to complete
- Verify that failed checks prevent the merge
- Verify that passed checks allow automatic merging

## Notes

- The auto-merge now uses GitHub's native `--auto` flag with `gh pr merge`
- This respects all branch protection rules you configure
- The previous `Mic92/auto-merge` action was merging PRs directly without
  checking status
