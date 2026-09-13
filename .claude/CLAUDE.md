<!-- Repo-specific instructions. The shared IshTech rules live in .claude/rules/ and are identical across repos; don't put repo-specific content there. -->
# hetu-validation-java

The owner's standing instructions are in `.claude/rules/` (`owner-workflow.md`, `git-and-branches.md`, `versions-and-releases.md`, `build-and-test.md`, `build-tooling.md`, `documentation.md`). They apply to every task in this repo. This file adds only what is specific to this repo.

## About this repo
- It's a library with no runnable application (`pom.xml` has no Spring Boot plugin, and there is no application class), so it has only test Level 1 of its own.
- Dependent tests apply (`rules/build-and-test.md`, section "Dependent tests"): they confirm that a change here doesn't break the projects that use `hetu-validation-java` and has the intended effect in them.
  - `hetu-validation-java` is public on Maven Central, so it may have other dependents that nobody can list.

## Read the doc before doing the thing
The docs are the source of truth. Don't guess commands: open the matching file and section first, and follow its links.

| Before you... | Read |
|---|---|
| work out what the library does and how consumers add it | `README.md`, the introduction. It has no section "Usage" yet (reported to the owner as a doc gap) |
| run test Level 1 (build with tests) | `README.md` has no build section yet (reported to the owner as a doc gap). Until it has one, use `./mvnw clean install` |
| publish (only when the owner asks) | `README.md` has no publish section yet (reported to the owner as a doc gap). Until it has one, see `.github/workflows/cicd.yml`, step "Publish to Maven Central Sonatype" |
| change the version or anything release-related, or check what CI enforces | `README.md` has no CI section yet (reported to the owner as a doc gap). Until it has one, read `.github/workflows/cicd.yml` |
| report or fix a bug | `KNOWN-ISSUES.md` (doesn't exist yet; create it as `rules/documentation.md` describes when the first issue is recorded) |

If a doc is missing, wrong or unclear, fix the doc (see `rules/documentation.md`) instead of working around it.
