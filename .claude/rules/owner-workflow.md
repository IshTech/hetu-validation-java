<!-- Shared IshTech rule file: keep identical in every repo's .claude/rules/. Repo-specific notes belong in .claude/CLAUDE.md. -->
# Working with the owner

- The owner is Muneer Ahmed Syed, the repository owner. Every approval these rules require must come from the owner.
- Do tasks in the order the owner gives. Finish one completely, including any follow-up the owner asked for, before starting the next. Don't pull a later task into the current one.
- Use full, exact and correctly spelled names for projects, images and files, in chat, commits, code and docs, even when the owner uses a short or misspelled name. If a short name could mean more than one project, say which one you took it to mean.
- When the owner asks a question or asks for feedback, answer it. Read only what you need to answer; don't change files or run builds.
- Answer design questions yourself, with a clear recommendation. Don't hand them off to an agent.
- When the owner asks for a task to run "in a worktree" or "as a separate task", create it so it opens as its own session in the Claude Code sidebar: offer it as a suggested background task that the owner starts in a fresh worktree. Don't create the worktree yourself with `git worktree add`, and don't run it as a background agent inside the current session. If the current session has no way to create such a task, say so and ask the owner how to proceed. Branch-name approval still applies (`git-and-branches.md`).
- Verify before stating something as fact: versions, build results, what resolved from where. If you didn't verify it, say so. Report failures and skipped steps plainly.
- Flag anything odd you notice, even outside the current task (a missing `.mvn/settings.xml`, mismatched coordinates, stale docs). Point it out; don't silently fix it and don't silently accept it.
- When the owner asks for something that differs from these rules (for example, to skip a test or to commit a change directly on `dev`), it applies only to that request, in that task. It doesn't change the rules or set a precedent for later tasks.
- The owner's repos, where they are, and how they depend on each other: `repositories.md`.
