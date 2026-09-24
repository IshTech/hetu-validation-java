<!-- Shared IshTech rule file: keep identical in every repo's .claude/rules/. Repo-specific notes belong in .claude/CLAUDE.md. -->
# Git: branches, merges, commits, pushes

Approval prompts in `.claude/settings.json` back up the rules below (creating branches, switching to `main`, merge, push, tag, hard reset, clean, publish), and its deny rules block deleting, renaming and force-pushing `main` and `dev`.

## Branches
- `dev` is the default working branch. `main` holds releases only.
- Never delete, rename, reset, force-push or rewrite `main` or `dev`, locally or on GitHub, including during branch or worktree cleanups.
- Every task gets its own feature branch, created from the latest `dev`. Never create a branch from `main`.
- Only when a part of the task needs to be kept apart from the rest (for example, a sub-task that the owner may want to review or drop on its own), create a child feature branch from the task's feature branch. Don't create child branches by default.
- A task that changes more than one repo uses the same branch name in every repo it changes.
- Creating any branch (including a worktree branch) and choosing its name needs the owner's explicit approval, every time, in every repo. Propose a name (default convention `feature/<short-topic>`; for a child branch, `feature/<short-topic>-<sub-topic>`), wait for approval, then create it. Never rename a branch without approval.
- Never commit directly to `main`. If there is truly no other way, stop, explain why, and get explicit approval first.
- Don't commit directly to `dev` either; work goes through feature branches and merges. The only exception is when the owner explicitly says to commit a specific change to `dev`.
- To check the current branch use `git rev-parse --abbrev-ref HEAD`; `git branch ...` triggers an approval prompt.

## Merges
- A branch is merged back only into the branch it was created from, one level at a time: a child feature branch into its feature branch, then the feature branch into `dev`.
- When a task (or a sub-task on a child branch) is complete, run the tests that `build-and-test.md` requires for a merge, report the results, and propose the merge into the parent branch. Ask the owner whether to merge locally or through a GitHub pull request, and merge only after the owner approves.
- Before merging, bring the parent branch's latest changes into the branch (merge the parent into it) and re-run the tests if anything came in.
- Merge with `--no-ff` (always create a merge commit) unless the owner says otherwise. For a GitHub pull request that means "Create a merge commit", not squash or rebase. The merge commit message is Git's default (`Merge branch '<branch>' into <parent>`).
- Merging `dev` into `main` happens only when the owner decides on a release, and the owner does it, manually, through a GitHub pull request. Never merge into `main`, and never create a release or tag. When the owner asks whether `dev` is ready, run the readiness check in `versions-and-releases.md`. Creating that pull request, or correcting its title and notes, is done only when the owner asks: `versions-and-releases.md`, section "Pull request from `dev` to `main`".

## Commits
- Commit only when the owner says so. Before each commit, show the owner the project name, the diff of every file in the commit and the proposed commit message, then wait. If anything changes after that, show it again and wait again.
- Commits are atomic and logically grouped: one commit per logical change, containing every file that change needs, and nothing else. Not one commit per file or per line, and not all of a task's changes in a single commit. A task may have one or more commits. Examples from the repos' history:
  - A version bump of the project or of one dependency is its own commit (`pom - 3.3.0 snapshot version`, `pom - ishtech-i18n update to 5.3.0 snapshot`).
  - A code change goes together with the tests and the doc updates that describe it.
  - Separate concerns go in separate commits, even in the same file set: `docker - install curl in runtime stage for compose healthcheck` and `docker - healthcheck to use container port instead of host port` are two commits.
  - Changes in different repos are always separate commits, one set per repo.
- Message style: short and lowercase, `<area> - <what changed>`, matching the repo's `git log`. Areas used so far: `pom`, `docker`, `cicd`, `claude`, `docs`, `api info`, `curl info`, `known issues`. Other forms in use: `mvn wrapper update to 3.9.16`, `fix <thing>`. No explanatory body. Run `git log -15 --format=%s` before writing one.

## Pushes
- Push only when the owner asks. After committing, always say whether it is pushed; never leave commits silently unpushed.
- Before pushing: `git fetch`, list exactly what will go out (`git log --oneline origin/<branch>..<branch>`; for a branch not yet on the remote, compare against the branch it was created from), and confirm it is only what the owner intended. Call out any other unpushed commits, including the owner's own, before pushing.
- Before pushing, run the tests that `build-and-test.md` requires for a push.
