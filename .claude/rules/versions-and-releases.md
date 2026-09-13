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

## Publishing upstream SNAPSHOTs before Level 3
When the upstream SNAPSHOTs that test Level 3 needs aren't published yet (for example because `dev` isn't pushed), work in this order:
1. Run test Levels 1 and 2 locally.
2. Only when the owner is satisfied with the results and explicitly asks: push `dev` and trigger the repo's manual deploy (`workflow_dispatch` with `manual_deploy=true`), one repo at a time in dependency order, upstream first (for example `ishtech-i18n-java`, then `ishtech-base-jpa`, then `ishtech-springboot-jwtauth`).
   - Wait for each deploy to succeed before pushing the next repo. The CI build that runs on every push resolves upstream SNAPSHOTs from Sonatype, so a repo pushed before its upstream SNAPSHOT is published is built against the old one and may fail.
   - Only the upstream repos need deploying for Level 3; the repo under test doesn't.
   - A manual deploy can publish more than SNAPSHOTs (for example a Docker image). Check the repo's CI workflow before triggering it.
3. Then run test Level 3.
