# Known Issues

Confirmed issues that are not fixed yet.

## 1. Release CI run fails although the release is published
**Status:** open
**Impact:** the CI run for a GitHub release is red even when the release reaches Maven Central
**Affects:** CI release runs (`.github/workflows/cicd.yml`, step "Publish to Maven Central Sonatype")

The same issue, with its description, steps to reproduce, likely cause and suggested fix, is recorded in [ishtech-validations-java, KNOWN-ISSUES.md, issue 1](https://github.com/IshTech/ishtech-validations-java/blob/dev/KNOWN-ISSUES.md#1-release-ci-run-fails-although-the-release-is-published). This repo uses the same plugin configuration (`central-publishing-maven-plugin` with `waitUntil=published` in `pom.xml`).
