<!-- Shared IshTech rule file: keep identical in every repo's .claude/rules/. Repo-specific notes belong in .claude/CLAUDE.md. -->
# Versions and releases

- `dev` and feature branches use a SNAPSHOT version (`x.y.z-SNAPSHOT`; a feature branch may add a qualifier, e.g. `x.y.z-topic-SNAPSHOT`). `main` uses a release version without SNAPSHOT.
- A version bump is its own commit.
- Library repos (published to Maven Central; see the publish section of the repo's README) have consumers you cannot know. Treat public classes, configuration properties and behaviour as a contract: a breaking change needs a major version bump and the owner's approval.
- Never publish anything unless the owner explicitly asks for that specific publish: no `deploy`, no `-P central-publishing` or `-P gpg`, no Docker image push, no release or tag.

## Readiness for the owner's pull request from `dev` to `main`
When the owner asks whether `dev` is ready, run every check below and report each result:
1. No SNAPSHOT dependencies: every ishtech dependency is a release version.
2. Test Level 1 passes (`build-and-test.md`).
3. Test Levels 2 and 3 pass, for repos that have them (`build-and-test.md`).
4. Dependent tests pass against the repo's default dependent, for repos that other repos depend on. Report whether they were done and each result, as `build-and-test.md`, section "Dependent tests", describes.

## Pull request from `dev` to `main`
The owner merges `dev` into `main` through a GitHub pull request (`git-and-branches.md`, section "Merges"). Its description is the release notes. Claude works on this pull request only when the owner asks, in one of two ways:
- Check or correct an existing one: compare its title and notes with the actual changes, report every mistake and omission, and propose a corrected title and notes.
- Create one: write the title and notes from scratch.

In both cases, show the proposed title and notes to the owner first. Update or create the pull request only after the owner approves them.

### Where the changes come from
Fetch `main` and `dev` first. Work from the actual changes, not from the commit messages alone, which can be misleading:
- `git log --oneline origin/main..origin/dev` for the list of commits.
- `git diff --stat origin/main...origin/dev`, then the diff of each file that matters, for what really changed.

A file that is the same on `main` and `dev` has no changes to report, even if commits on `dev` touched it.

### Title
`Dev to main - x.y.z`, where `x.y.z` is the version in `pom.xml` on `dev` without `-SNAPSHOT` (for example `5.3.0-SNAPSHOT` gives `Dev to main - 5.3.0`).

### Notes
Content:
- High level: one line for each change that matters to someone who uses or maintains the library, grouped by area, with sub-bullets for details. Not one line per commit or per file.
- Complete and accurate: every change that matters is listed, and nothing is listed that isn't in the diff.
- The first line is `POM version x.y.z`, the same version as in the title. Its sub-bullets list dependency and plugin version updates, using the new version only (`<dependency or plugin> version <new version>`). An upstream library of the owner is listed the same way, with its version without `-SNAPSHOT`.
- State every breaking change explicitly, because consumers can't find out about it any other way. For example: a changed `groupId` or `artifactId`, renamed packages or classes, and renamed validation message keys or configuration properties. A package refactor doesn't imply a `groupId` change, so name both (`package and groupId refactor from <old> to <new>`, or separate old and new values when the package and the `groupId` differ). A breaking change also needs a major version bump (see the top of this file); if the version isn't one, point that out to the owner.
- For a first release, where `main` has only a skeleton (for example an empty README), use `initial code` with a short phrase saying what the code provides, and `readme - initial documentation`.
- Leave out changes that matter to nobody who uses or maintains the library, such as reformatting code.

Style:
- Follow the style of earlier notes, not a fixed template: the areas and lines depend on what actually changed. Read the descriptions of the most recent pull requests from `dev` to `main` in this repo (open and merged), newest first. The newer a note is, the more weight it has: older notes may predate this section. If this repo has none yet (a first release), use the most recent ones of the owner's sibling libraries (`repositories.md`).
- Short, lowercase `<area> - <what changed>` lines.
- Correct typos and grammar, including in wording the owner gives.
- The description contains only the notes, without any other text.

### Creating the pull request
- First check whether an open pull request from `dev` to `main` already exists. If it does, correct that one instead of creating another.
- Base `main`, head `dev`, with the approved title and notes.
- Create it as a draft, unless the owner asks for it to be ready for review. Mark it ready for review only when the owner asks. If the readiness check (section "Readiness for the owner's pull request from `dev` to `main`") hasn't passed on the latest `dev`, say so first.
- Don't add reviewers, labels or auto-merge, and never merge it.

### Keeping the pull request up to date
Check the title and notes against `dev`, as described above, only when the owner asks, and before a release (for example after the release version is set in `pom.xml`). Propose the corrections to the owner as described at the start of this section.

## Publishing upstream SNAPSHOTs before Level 3
When the upstream SNAPSHOTs that test Level 3 needs aren't published yet (for example because `dev` isn't pushed), work in this order:
1. Run test Levels 1 and 2 locally.
2. Only when the owner is satisfied with the results and explicitly asks: push `dev` and trigger the repo's manual deploy (`workflow_dispatch` with `manual_deploy=true`), one repo at a time in dependency order, upstream first (for example `ishtech-i18n-java`, then `ishtech-base-jpa`, then `ishtech-springboot-jwtauth`).
   - Wait for each deploy to succeed before pushing the next repo. The CI build that runs on every push resolves upstream SNAPSHOTs from Sonatype, so a repo pushed before its upstream SNAPSHOT is published is built against the old one and may fail.
   - Only the upstream repos need deploying for Level 3; the repo under test doesn't.
   - A manual deploy can publish more than SNAPSHOTs (for example a Docker image). Check the repo's CI workflow before triggering it.
3. Then run test Level 3.
