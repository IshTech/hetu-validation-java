<!-- Shared IshTech rule file: keep identical in every repo's .claude/rules/. Repo-specific notes belong in .claude/CLAUDE.md. -->
# Versions and releases

- `dev` and feature branches use a SNAPSHOT version (`x.y.z-SNAPSHOT`; a feature branch may add a qualifier, e.g. `x.y.z-topic-SNAPSHOT`). `main` uses a release version without SNAPSHOT.
- A version bump is its own commit.
- Library repos (published to Maven Central; see the repo's README, section "Publish to Maven Central") have consumers you cannot know. Treat public classes, configuration properties and behaviour as a contract: a breaking change needs a major version bump and the owner's approval.
- Never publish anything unless the owner explicitly asks for that specific publish: no `deploy`, no `-P central-publishing` or `-P gpg`, no Docker image push, no release or tag.

## Readiness for the owner's pull request from `dev` to `main`
When the owner asks whether `dev` is ready, run every check below and report each result:
1. The release criteria are met (section "Release criteria").
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

## Release criteria
Before `dev` is merged into `main`, `pom.xml` on `dev` must meet all of these:
1. The project version has no `-SNAPSHOT`.
2. Every dependency on one of the owner's libraries (`groupId` starting with `fi.ishtech`) has a release version, not a SNAPSHOT version.
3. Each of those release versions is on Maven Central: `https://repo1.maven.org/maven2/<groupId, with each dot replaced by a slash>/<artifactId>/maven-metadata.xml` lists it.

So a library is released only after the owner's libraries it depends on are released. Release one repo at a time, upstream first (`repositories.md`, section "Order of work across repos").

## Release
The owner decides when to release and which version. The owner can do any step below, or ask Claude to do one or more of them. A request to do a step includes the permissions that step needs (a direct commit on `dev`, the merge into `main`, publishing the release). Claude stops and reports when a check fails or a decision belongs to the owner.

Unless the owner asks for several repos to be released together, release one repo at a time: complete its release, including step 8 (Verification), before starting the next. The order of section "Release criteria" still applies.

The version commits below (steps 1, 2 and 9) go directly on `dev`. When the owner hasn't asked for these steps, ask first, giving the reason: it is a one-line version change in `pom.xml`, which in steps 1 and 2 must be among the last commits on `dev` before the merge into `main`.

### Version
The owner decides the version. At the start of the preparation, recommend one, with the reasons, based on the changes from `main` to `dev`:
- Minor (`x.y.0`): the default.
- Major (`x.0.0`): when there is a breaking change (see the top of this file), or when the Java version (`java.version` in `pom.xml`) changes. List each breaking change found.
- Patch (`x.y.z`): only when the owner asks for a release with bug fixes only.

If the recommended version differs from the version in `pom.xml` on `dev` (without `-SNAPSHOT`), say so; step 2 then sets the version the owner decides.

### Preparation
1. In `pom.xml` on `dev`, set each dependency on the owner's libraries to its release version. Commit `pom - <artifactId> x.y.z`, one commit per dependency.
2. In `pom.xml` on `dev`, set the project version to the release version, without `-SNAPSHOT`. Commit `pom - x.y.z release version`.
3. Check the CI runs on `dev` (GitHub Actions):
   - The run for the commit `pom - x.y.z release version` is expected to fail, only in the step "Validate Project Version", with the error that a branch other than `main` must use a SNAPSHOT version. That confirms the version check works.
   - Every other run on `dev` since the previous release must have succeeded, or have been followed by a successful run.
   - Report any other failure to the owner, with the failing step and its error, and wait for the owner to decide whether to go on with the release.
4. Run the readiness check (section "Readiness for the owner's pull request from `dev` to `main`").
5. Update the title and notes of the pull request from `dev` to `main` (section "Pull request from `dev` to `main`").

### Merge
6. Merge the pull request from `dev` to `main`.
   - Preconditions: steps 1 to 5 are done, and no commit has been added to `dev` since steps 3 and 4 checked it (the pull request's head is that commit); the pull request has no merge conflicts.
   - GitHub web UI: on the pull request, choose "Create a merge commit" (not squash or rebase), keep the default commit message, and confirm.
   - gh CLI: `gh pr merge <number> --repo <owner>/<repo> --merge`
   - After merging: the CI run for the merge commit on `main` must succeed ("Validate Project Version", "Maven Compile" and "Maven Test" pass; "Import GPG key" and "Publish to Maven Central Sonatype" are skipped). If it fails, stop and report to the owner.

### Publish
7. Publish the GitHub release. CI then publishes the release to Maven Central.
   - Preconditions: step 6 is done and its CI run on `main` succeeded; the version in `pom.xml` on `main` is `x.y.z`; no tag `vx.y.z` exists yet.
   - Tag `vx.y.z` on the latest commit of `main`, title `vx.y.z`. Description:
     - a heading `## What's Changed`, followed by the notes of the pull request;
     - a line `- Dev to main - x.y.z by @<author of the pull request> in <link to the pull request>`;
     - a last line `**Full Changelog**: https://github.com/<owner>/<repo>/compare/v<previous version>...vx.y.z`, or `**Full Changelog**: https://github.com/<owner>/<repo>/commits/vx.y.z` for a first release.
   - GitHub web UI: Releases → "Draft a new release" → "Choose a tag": type `vx.y.z` and select "Create new tag: vx.y.z on publish" → Target: `main` → Release title: `vx.y.z` → paste the description → leave "Set as a pre-release" unticked → tick "Set as the latest release" → "Publish release".
   - gh CLI: save the description as `notes-vx.y.z.md`, then:
     `gh release create vx.y.z --repo <owner>/<repo> --target main --title "vx.y.z" --notes-file notes-vx.y.z.md --latest`
   - If Claude does this step but the session has no way to create a release (no `gh` with a token), give the owner the description and the command instead.

### Verification
8. Check that the CI run for the GitHub release succeeded, including "Publish to Maven Central Sonatype", and that version `x.y.z` is on Maven Central (the URL is in section "Release criteria", criterion 3).

### After the release
9. In `pom.xml` on `dev`, set the next minor SNAPSHOT version (for example `5.3.0-SNAPSHOT` after `5.2.0`), unless the owner gives another. Commit `pom - x.y.z snapshot version`.

## JDK variants
`dev` and `main` use the default JDK version, the latest LTS version (`java.version` in `pom.xml`), and their code and dependencies are kept at the latest available versions. They never keep older code or older dependency versions only to stay compatible with an earlier JDK.

A library can also be released for other supported JDK versions. The README, section "Tech stack", lists the default JDK version and the other supported JDK versions; each other supported JDK version has a branch `dev-jdkNN` in the repo. If that list doesn't match `java.version` in `pom.xml` on `dev`, or doesn't match the branches (`git ls-remote --heads origin 'dev-jdk*'`), tell the owner. When the owner adds or drops a supported JDK version, update that list in the same task. In this section, `NN` stands for such a JDK version (for example `21`). Names always use `jdkNN`, lowercase, without a hyphen between `jdk` and the number; text uses "JDK NN".

Each branch `dev-jdkNN`:
- Is never merged into `dev` or `main`.
- Differs from `dev` in:
  - the project version, with the suffix `-jdkNN`;
  - `java.version`, set to `NN`;
  - the JDK version in the "Set up JDK" step of `.github/workflows/cicd.yml`;
  - every dependency on the owner's libraries, with the same suffix `-jdkNN`;
  - the compatibility changes JDK NN needs: code changed, or dependencies left at an earlier version, only where the code on `dev` doesn't compile or pass its tests on JDK NN.
- Keeps these differences when `dev` or a release tag is merged into it.
- Uses the version `x.y.z-jdkNN-SNAPSHOT` between releases, and `x.y.z-jdkNN` for a release, where `x.y.z` is the version of the release it is built from.
- Gets commits and merges only with the owner's permission, as for `dev`.

### Keeping a JDK variant up to date (optional)
When the owner asks: merge `dev` into `dev-jdkNN`, then run Level 1 (`build-and-test.md`) with JDK NN. This finds incompatibilities before the next release. If the build fails, propose the compatibility change to the owner.

### Releasing a JDK variant
Only after the release `x.y.z` has passed "Verification" (section "Release", step 8), and only when the owner asks. One repo at a time, upstream first, as in section "Release criteria".

1. Merge the tag `vx.y.z` into `dev-jdkNN`.
2. In `pom.xml` on `dev-jdkNN`, set each dependency on the owner's libraries to its release version with the suffix `-jdkNN`. Commit `pom - <artifactId> a.b.c-jdkNN`.
3. In `pom.xml` on `dev-jdkNN`, set the project version to `x.y.z-jdkNN`. Commit `pom - x.y.z-jdkNN release version`.
4. Run the readiness check (section "Readiness for the owner's pull request from `dev` to `main`") on `dev-jdkNN`, with JDK NN. Release criteria 2 and 3 apply with the suffix: each dependency on the owner's libraries has a release version with the suffix `-jdkNN`, and that version is on Maven Central.
5. Check the CI runs on `dev-jdkNN`, as in section "Release", step 3.
6. Publish the GitHub release, as in section "Release", step 7, with these differences:
   - Preconditions: steps 1 to 5 are done; the version in `pom.xml` on `dev-jdkNN` is `x.y.z-jdkNN`; no tag `vx.y.z-jdkNN` exists yet.
   - Tag `vx.y.z-jdkNN` on the latest commit of `dev-jdkNN`, title `vx.y.z-jdkNN`. The description has no pull request line; its last line is `**Full Changelog**: https://github.com/<owner>/<repo>/compare/v<previous version>-jdkNN...vx.y.z-jdkNN`.
   - GitHub web UI: Target: `dev-jdkNN`; leave "Set as the latest release" unticked.
   - gh CLI: `gh release create vx.y.z-jdkNN --repo <owner>/<repo> --target dev-jdkNN --title "vx.y.z-jdkNN" --notes-file notes-vx.y.z-jdkNN.md --latest=false`
7. Check that the CI run for the GitHub release succeeded, and that version `x.y.z-jdkNN` is on Maven Central.
8. In `pom.xml` on `dev-jdkNN`, set the next SNAPSHOT version with the same number as on `dev` (for example `6.1.0-jdk21-SNAPSHOT` when `dev` has `6.1.0-SNAPSHOT`). Commit `pom - x.y.z-jdkNN snapshot version`.

## Publishing upstream SNAPSHOTs before Level 3
When the upstream SNAPSHOTs that test Level 3 needs aren't published yet (for example because `dev` isn't pushed), work in this order:
1. Run test Levels 1 and 2 locally.
2. Only when the owner is satisfied with the results and explicitly asks: push `dev` and trigger the repo's manual deploy (`workflow_dispatch` with `manual_deploy=true`), one repo at a time in dependency order, upstream first (for example `ishtech-i18n-java`, then `ishtech-base-jpa`, then `ishtech-springboot-jwtauth`).
   - Wait for each deploy to succeed before pushing the next repo. The CI build that runs on every push resolves upstream SNAPSHOTs from the Sonatype snapshot repository, so a repo pushed before its upstream SNAPSHOT is published is built against the old one and may fail.
   - Only the upstream repos need deploying for Level 3; the repo under test doesn't.
   - A manual deploy can publish more than SNAPSHOTs (for example a Docker image). Check the repo's CI workflow before triggering it.
3. Then run test Level 3.
