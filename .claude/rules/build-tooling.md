<!-- Shared IshTech rule file: keep identical in every repo's .claude/rules/. Repo-specific notes belong in .claude/CLAUDE.md. -->
# Build tooling

- Update generated or managed files with the tool's own command, not by hand-editing.
- Dependency and plugin versions are declared once and referenced: Maven `<properties>` in `pom.xml`, Gradle `val` declarations at the top of `build.gradle.kts`. Change the declaration, not the usage.
- Check the latest release before upgrading (Maven Central `maven-metadata.xml`, or `https://services.gradle.org/versions/current`). Use stable releases, not milestones or RCs.
- Don't change `.gitattributes` without the owner's approval.

## JDK
- Build on the JDK the branch requires. Maven: `java.version` in `pom.xml`. Gradle: `languageVersion` in the `java { toolchain { ... } }` block of `build.gradle.kts`. On a `dev-jdkNN` branch that value is `NN` (`versions-and-releases.md`, section "JDK variants"). Never lower it to match an installed JDK, and never build on a different JDK; install the required one instead.
- Maven and Gradle follow `JAVA_HOME`, not the `java` on `PATH`. Check both (`java -version`, `echo $JAVA_HOME`) before a build, and set `JAVA_HOME` to the required JDK.
- Gradle does not fetch a missing toolchain JDK: no toolchain resolver is configured, so the build fails instead of downloading one. Install it the same way as for Maven.
- On Linux, including a cloud session, install a missing JDK from the Adoptium apt repository, as root, replacing `NN` with the required version:
  ```
  apt-get update -qq && apt-get install -y -qq wget gpg apt-transport-https
  wget -qO- https://packages.adoptium.net/artifactory/api/gpg/key/public \
    | gpg --dearmor > /etc/apt/trusted.gpg.d/adoptium.gpg
  echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print $2}' /etc/os-release) main" \
    > /etc/apt/sources.list.d/adoptium.list
  apt-get update -qq && apt-get install -y -qq temurin-NN-jdk
  export JAVA_HOME=/usr/lib/jvm/temurin-NN-jdk-amd64
  export PATH="$JAVA_HOME/bin:$PATH"
  ```
  This needs no approval: it changes nothing in any repo and nothing outside the session. Report which JDK was installed.
- A cloud session starts with a new container, so the install repeats each session. It needs `packages.adoptium.net` to be reachable; if it isn't, stop and tell the owner, because only the owner can allow it.
- On the owner's Windows machine, the owner manages the installed JDKs. If the required one is missing there, say so instead of installing it.

## Maven wrapper (Apache Maven Wrapper, only-script)
- Upgrade: `rm -f mvnw mvnw.cmd && rm -rf .mvn/wrapper`, then run with the system `mvn` (not `./mvnw`, which rewrites itself mid-run):
  `mvn -N org.apache.maven.plugins:maven-wrapper-plugin:<wrapper-version>:wrapper -Dmaven=<maven-version> -Dtype=only-script`
- `-N` keeps it at the root of multi-module projects. Verify with `./mvnw -v`.
- Delete only `.mvn/wrapper/`, never `.mvn/`: `.mvn/settings.xml` is needed by CI, Docker builds and publishing. Every Maven repo should have one; flag it if it's missing.
- Don't add `distributionSha256Sum`. The Docker build image has no `unzip`, so the wrapper downloads the `.tar.gz` instead of the `.zip`, and a zip checksum would fail every container build.
- Don't use the takari wrapper (unmaintained since 2019).

## Gradle wrapper
- Upgrade with `./gradlew wrapper --gradle-version <version>`, run twice: the second run regenerates the scripts and jar using the new version. The wrapper jar stays committed.
