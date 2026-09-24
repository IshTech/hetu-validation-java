<!-- Shared IshTech rule file: keep identical in every repo's .claude/rules/. Repo-specific notes belong in .claude/CLAUDE.md. -->
# Build and test

- Read the repo's README, and the docs it links, before choosing any build, run, test or Docker command. Commands, profiles, ports and database needs differ between repos.
- Always use the wrapper: `./mvnw` or `./gradlew`.

## Test levels
There are three test levels. Level 2 applies to repos whose docs describe running the app, and Level 3 to repos whose docs describe running it with Docker; a library with no runnable application has only Level 1. The repo's `.claude/CLAUDE.md` names the doc and section to use for each level.

When each level runs:
- Level 1 is the default: run it for every change. It must pass before any push and before any merge.
- On a feature branch, Levels 2 and 3 are on demand. Before merging a feature branch into `dev`, or a child feature branch into its parent, ask the owner whether to run Level 2, Level 3, or both.
- When the owner asks whether `dev` is ready to merge into `main`, run Levels 2 and 3 as part of the readiness check in `versions-and-releases.md`.

### Level 1: build with tests
- Run the build-with-tests command from the repo's README.
- Maven: on any branch other than `dev`, run that command with `verify` instead of `install`, unless the task uses a temporary local repository ("Cross-repo builds"), so that `~/.m2` keeps only builds of `dev`.
- Gradle: `./gradlew clean build` doesn't install anything into `~/.m2`, so run it as the README gives it, on any branch.
- Passes when the build succeeds with no compile errors and no test failures or errors. Report the test counts.

### Level 2: run the app with Maven/Gradle
Start the app the way the repo's docs describe (command, profile, database), on a free port. Then check, in order:
1. Start-up: the log shows the application's "Started ..." line with no startup errors, and the app is listening on the expected port.
2. Health: `GET /actuator/health` on that port returns HTTP 200 with `"status":"UP"`. Also check any other actuator endpoints the docs mention.
3. API tests: run the API/curl flows from the docs the README links (`CURL-INFO.md`, and `TEST-SUITE.md` where present) against that port, and report each call as expected vs actual status.

Afterwards, stop the app and make sure the forked JVM has exited too; stopping Maven alone can leave it listening on the port.

### Level 3: build and run with Docker
Precondition: the Docker build resolves the repo's upstream SNAPSHOT dependencies (for example `ishtech-base-jpa` and `ishtech-i18n`) from the Sonatype snapshot repository, not from the local Maven repository. The repo's own code is copied into the image, so its own SNAPSHOT doesn't need to be published. Level 3 therefore tests the latest upstream code only when the published upstream SNAPSHOTs contain it. If they don't yet, Level 3 can still run, but its result may not be reliable; say so in the report. How to publish them first: `versions-and-releases.md`, section "Publishing upstream SNAPSHOTs before Level 3".

Build and start the app with docker compose as the repo's Docker doc describes. Use host ports that are free and don't clash with other running apps (the doc lists the port variables). Use the compose file's own database service when it defines one, not a local database. Then check, in order:
1. Start-up: the app container is running, and its log (`docker logs <container>`) shows the application's "Started ..." line with no startup errors.
2. Health: `GET /actuator/health` on the mapped host port returns HTTP 200 with `"status":"UP"`. Also check any other actuator endpoints the docs mention. Check from the host; don't rely on the container's Docker health status alone.
3. API tests: run the API/curl flows from the docs the README links (`CURL-INFO.md`, and `TEST-SUITE.md` where present) against the mapped host port, and report each call as expected vs actual status.

Afterwards, tear the stack down with `docker compose down -v`.

### For every level
- Check a port is free before using it, and prefer alternative ports: other sessions may be using the defaults.
- Test data: use unique, obviously-test identifiers (e.g. `apitest-<timestamp>@example.com`) and delete what you created in any shared or dev database afterwards.
- If a check fails, establish whether it's pre-existing (e.g. reproduce on the previous commit) before calling it a regression.

## Dependent tests
A dependent is a repo that declares this repo's artifact as a dependency in its build file (`pom.xml` or `build.gradle.kts`). Dependent tests are for repos that other repos depend on. They are separate from the test levels.

Purpose: to confirm that a change in this repo does not break its dependents and has the intended effect in them. This matters most before a release, so dependent tests are required for the `dev` to `main` readiness check (`versions-and-releases.md`).

They run:
- when the owner asks (for example: "test these `ishtech-base-jpa` changes in `ishtech-springboot-jwtauth`, so I'm sure they don't break anything and do what's intended"), and
- always, as part of the readiness check.

If the owner doesn't name a dependent, use the default dependent listed in the repo's `.claude/CLAUDE.md`. If it lists none, ask the owner which dependent to use; in the readiness check, report the dependent tests as not done for that reason unless the owner names one.

Steps:
1. Choose where the dependent gets the changed library from. If the owner hasn't said, ask:
   - Local build: build the changed library in this task as section "Cross-repo builds" describes for an upstream repo changed in the task, so the dependent resolves that build.
   - Published SNAPSHOT: the version in the Sonatype snapshot repository. Use it only if you can confirm it was published from the branch being tested, after that branch's latest commit (compare the timestamp in the Sonatype snapshot repository's `maven-metadata.xml` with that commit's time). If you can't confirm both, say so and ask the owner. To stop a Maven dependent from resolving a local build instead, build it with an empty temporary local repository (`-Dmaven.repo.local=<temporary directory>`).
2. Check that the dependent declares the library version being tested. If it doesn't, ask the owner before changing the dependent's build file.
3. Confirm which library artifact the dependent actually resolved (Maven: `./mvnw dependency:list`; Gradle: `./gradlew dependencies`).
4. In the dependent, run the test levels the owner asks for; for the readiness check, run all of the dependent's test levels. Follow the dependent's own `.claude/CLAUDE.md` and docs.
5. Report per dependent: done or not done (and why), the library source used (local build or published SNAPSHOT), the result of each test level, and whether the change had the intended effect, not just that nothing broke.

## Cross-repo builds
An upstream repo is one of the owner's repos whose artifact a repo being built declares as a SNAPSHOT dependency, directly or through another upstream repo. A dependency on a released version is fixed and needs none of the steps in this section.

- Build order: decide it from the declared versions in the build files (overview: `repositories.md`, section "Order of work across repos"). Build each upstream repo before the repos that depend on it. Repos with no dependency path between them can be built in parallel.
- A library's `.claude/CLAUDE.md` lists only the owner's other libraries that depend on it, and its default dependent for dependent tests, if it has one. Applications that use a library aren't listed, because a published library can be used by anyone (`repositories.md`). To find which of the owner's repos use a library, search their build files (`pom.xml`, `build.gradle.kts`). If those repos aren't available (e.g. in a cloud or mobile session), say in your report which dependents weren't checked or tested.

### Which build of an upstream repo to use
The local Maven repository `~/.m2` holds only builds of each repo's latest `dev`. Every other build goes into a temporary local repository (see "Temporary local repository" below), so it never replaces them.

For each upstream repo, use the first row that applies:

| Upstream repo | Build to use | Where the build comes from |
|---|---|---|
| Changed in this task | This task's branch of it | Build and test it in this task, and install it into the temporary local repository. |
| Not changed in this task, and the owner names a branch of it for this task | That branch | Build and test it in this task from a clean checkout of that branch, and install it into the temporary local repository. |
| Not changed in this task, and the owner names no branch | Its latest `dev` | Use the build in `~/.m2` if it is a build of the latest `dev` (checks below). If it isn't, ask the owner for permission; then build and test it from a clean checkout of `dev`, and install it into the temporary local repository. |

A build in `~/.m2` counts as a build of the latest `dev` only if both checks pass:
1. It was installed after the latest commit on `dev`: `lastUpdated` in `maven-metadata-local.xml`, in the artifact's SNAPSHOT version directory (UTC, format `yyyyMMddHHmmss`), is later than the commit time from `git log -1 --format=%cI dev`.
2. No other local branch of that repo has a commit later than the latest commit on `dev`.

If either check fails, or can't be done, the build doesn't count.

A clean checkout is a working tree at the branch's latest commit with no uncommitted changes. If none exists, ask the owner how to get one. Don't switch the branch of an existing checkout.

### Temporary local repository
- Use one only when the table above requires it. Create one new directory per task, outside every repo (for example in the session's scratchpad).
- When a task changes more than one repo, tell the owner at the start, together with the branch-name approval, that builds will install into a temporary local repository, and get their confirmation. If the owner declines, install into `~/.m2` instead, and say in the report that the `dev` builds there were replaced.
- Add these options to every Maven command of the task, including builds, runs, `dependency:list` and `help:*`: `-Dmaven.repo.local=<temp> -Dmaven.repo.local.tail=<home>/.m2/repository`. `<temp>` is the directory's absolute path; `<home>` is the absolute path of the user's home directory, because Maven doesn't expand `~`. Maven then installs only into `<temp>`, and reads everything else from `~/.m2` without changing it. This needs Maven 3.9 or later (check with `./mvnw -v`).
- Gradle (`springboot-books-app`): its `mavenLocal()` repository reads the temporary repository when `-Dmaven.repo.local=<temp>` is passed to `./gradlew`. Gradle has no equivalent of `maven.repo.local.tail`, so every SNAPSHOT of the owner's libraries that it doesn't find there resolves from the Sonatype snapshot repository instead of `~/.m2`. Therefore install every upstream SNAPSHOT the Gradle build needs into the temporary repository, and confirm with `./gradlew dependencyInsight --dependency <artifactId> -Dmaven.repo.local=<temp>`.
- Delete the directory after the task's last Maven or Gradle command, and say so in the report.

Level 3 isn't affected: the Docker build resolves upstream SNAPSHOTs from the Sonatype snapshot repository, not from a local repository.

### Build and test in order
1. Build every upstream repo that the table says to build, and every repo changed in this task, in the build order.
2. For each repo, run its Level 1 command. Use `install` instead of `verify` or `test` for every repo that another repo in the task depends on.
3. If a repo fails, don't build the repos that depend on it; report them as not run.
4. For each repo that has upstream repos, confirm that every upstream artifact resolved from the location the table gives: run `./mvnw dependency:list -DoutputAbsoluteArtifactFilename=true` (Gradle: `./gradlew dependencyInsight --dependency <artifactId>`) with the same options as the build. If any resolved from somewhere else (for example the remote snapshot repository), stop and report it.
