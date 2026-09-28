<!-- Shared IshTech rule file: keep identical in every repo's .claude/rules/. Repo-specific notes belong in .claude/CLAUDE.md. -->
# Documentation

- READMEs, and the docs they link, are the source of truth for humans and AI alike. Keep project facts there, not in `.claude/`: `.claude/` files point to README sections instead of repeating them.
- Update the README and docs in the same task whenever code, features, commands, ports or setup change.
- If a doc is wrong or unclear (e.g. a port that doesn't match the compose file), fix the doc and mention it. Don't silently work around it.
- Write every change to a doc or to a Claude file (under `.claude/`) in professional, grammatical English that is clear, unambiguous and self-sufficient, even when the owner's request is short or informal. Before presenting the change, reread the changed text as someone who is using it for the first time and has no other context: every step must be doable without guessing or asking, and the text must reflect every intention the owner stated. Fix anything that fails this check before showing the change to the owner.
- Confirmed bugs found by testing but not yet fixed go in the repo-root `KNOWN-ISSUES.md`, linked from the README under `## Known Issues`. One numbered entry per issue, with **Status**, **Impact** and **Affects**, then Description, Steps to reproduce, Likely cause and Suggested fix: enough to fix it without re-investigating.
- A `KNOWN-ISSUES.md` with no entries (only its heading and introduction) is normal: it means the project has no known issues at the moment. Don't report it as a problem.
- Before adding an issue, check whether it's already recorded in this repo, and in sibling repos when they're available. Don't duplicate it.
- Keep the repo root uncluttered: Claude-specific files live only in `.claude/`.
- `HELP.md`, where present, is Spring Initializr boilerplate, not project documentation. Don't use it or point to it.
