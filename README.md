# Nix runs the 🌍🌎🌏

Here you have my nix config files.

Nothing too fancy.

Love Blueprint

## `mvim`

`mvim` is my own bespoke neovim config based on
[LazyVim](https://www.lazyvim.org) and `nix`.

### `nix run`

Try it yourself...

```console
nix run github:multivac61/nixos-config#mvim
```

### Automatic update of `flake.lock` and `lazy.nvim`

Relevant files are found under
- `./home/nvim/` -- my lua files 
- `./packages/mvim.nix` -- standalone package
- `./modules/home/nvim.nix` -- home-manager module

Then you can set up the GitHub Action stuff like so...
`./.github/workflows/update-flake-lock.yml` and
`./.github/workflows/update-lazy-plugins.yaml` use the
[create-github-app-token](https://github.com/actions/create-github-app-token?tab=readme-ov-file#usage)
action. In order to use it in your project you need to
[register a new GitHub app](https://docs.github.com/en/apps/creating-github-apps/registering-a-github-app/registering-a-github-app).
In order to use this action, you need to:

1. [Register new GitHub App](https://docs.github.com/en/apps/creating-github-apps/registering-a-github-app/registering-a-github-app#registering-a-github-app).
   When creating the app you need to enable read and write access for "Contents"
   and "Pull Requests" permissions.
2. Next you must
   [install the app to make it available to your repo](https://docs.github.com/en/apps/using-github-apps/installing-your-own-github-app#installing-your-own-github-app)
   .
3. [Store the App's ID in your repository environment variables](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/store-information-in-variables#creating-configuration-variables-for-a-repository)
   as `CI_APP_ID`.
4. [Store the App's private key in your repository secrets](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/store-information-in-variables#creating-configuration-variables-for-a-repository)
   as `CI_PRIVATE_KEY`.
5. Create a new `auto-merge`
   [label in the GitHub UI](https://docs.github.com/en/issues/using-labels-and-milestones-to-track-work/managing-labels#creating-a-label).
6. [Enable auto-merge in your GitHub repo settings](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-auto-merge-for-pull-requests-in-your-repository#managing-auto-merge).
7. Set up branch protection:

- Go to repository Settings
- Click "Branches" in the left sidebar
- Click "Add branch protection rule"
- For "Branch name pattern" enter: main
- Check "Require status checks to pass before merging"
- In the search box, type "Auto Merge Dependency Updates"
- Also search for and add your ci workflow, e.g., building all systems using
  [determinate-ci](https://github.com/DeterminateSystems/ci/tree/main) or
  similar

Now you can upload the code and go to town with a sparking new auto-updating neovim config!

> [!NOTE]
> Lots of the `nix` and CICD code is adopted from the venerable
> [Mic92](https://github.com/Mic92/dotfiles)

