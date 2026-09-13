<!-- Shared IshTech rule file: keep identical in every repo's .claude/rules/. Repo-specific notes belong in .claude/CLAUDE.md. -->
# Build tooling

- Update generated or managed files with the tool's own command, not by hand-editing.
- Dependency and plugin versions are pom properties: change the property, not the usage.
- Check the latest release before upgrading (Maven Central `maven-metadata.xml`, or `https://services.gradle.org/versions/current`). Use stable releases, not milestones or RCs.
- Don't change `.gitattributes` without the owner's approval.

## Maven wrapper (Apache Maven Wrapper, only-script)
- Upgrade: `rm -f mvnw mvnw.cmd && rm -rf .mvn/wrapper`, then run with the system `mvn` (not `./mvnw`, which rewrites itself mid-run):
  `mvn -N org.apache.maven.plugins:maven-wrapper-plugin:<wrapper-version>:wrapper -Dmaven=<maven-version> -Dtype=only-script`
- `-N` keeps it at the root of multi-module projects. Verify with `./mvnw -v`.
- Delete only `.mvn/wrapper/`, never `.mvn/`: `.mvn/settings.xml` is needed by CI, Docker builds and publishing. Every Maven repo should have one; flag it if it's missing.
- Don't add `distributionSha256Sum`. The Docker build image has no `unzip`, so the wrapper downloads the `.tar.gz` instead of the `.zip`, and a zip checksum would fail every container build.
- Don't use the takari wrapper (unmaintained since 2019).

## Gradle wrapper
- Upgrade with `./gradlew wrapper --gradle-version <version>`, run twice: the second run regenerates the scripts and jar using the new version. The wrapper jar stays committed.
