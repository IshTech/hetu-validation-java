# Running CI/CD across several repos
This file covers CI/CD runs on GitHub Actions. For builds and tests on the local machine, follow `build-and-test.md`, section "Cross-repo builds".

When the owner asks to run the CI/CD workflow of several repos and some of them depend on others, ask the owner first whether to wait for the dependencies, unless the request already says so (for example "check and use dependency"). Check the dependencies both in the Claude files (`repositories.md` and each repo's `.claude/CLAUDE.md`) and in the build files (`pom.xml` or `build.gradle.kts`); where they disagree, the build files take precedence (`repositories.md`, section "Order of work across repos").

If the owner wants the wait, for each repo B that depends on a repo A in the request:
1. Start A's CI and let it complete. Check that it succeeded.
2. Check that the artifact built by this run of A is available, not just an earlier build of the same version:
   - SNAPSHOT: `<lastUpdated>` in its `maven-metadata.xml` in the Sonatype snapshot repository is later than the start of A's run.
   - Release: Maven Central lists the version.
3. Only then start B's CI, so that B uses that artifact.

If A's CI fails or its artifact isn't available, tell the owner. The owner decides whether to stop or to proceed anyway; the default is stop.

B waits for A only if B uses the version that A's run builds. For example, if B uses A `1.0.0` and A's run builds `1.1.0-SNAPSHOT`, B doesn't wait.

After the runs, confirm that each dependent used the right jars. When its run publishes a Docker image, check the jars of the owner's libraries inside the image (`BOOT-INF/lib/` in the application jar): the build time of each must fall inside the run of A that built it.

In the final report, give the result of every repo that was run, including the ones no other repo waited for, and the result of the jar check.
