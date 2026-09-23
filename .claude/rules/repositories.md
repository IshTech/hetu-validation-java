<!-- Shared IshTech rule file: keep identical in every repo's .claude/rules/. Repo-specific notes belong in .claude/CLAUDE.md. -->
# The owner's repositories

## Where they are
- GitHub: the URLs below. The case of the owner part (`ishtech` / `IshTech`, `muneer2ishtech`) doesn't matter.
- Owner's machine (Windows): library repos under `D:\Work\IshTech\code\`, practice (application) repos under `D:\Practice\IshTech\code\`. Each subfolder is its own git repo; the parent folders are not.
- On another machine, or in a cloud or mobile session, only some of them (possibly only the current repo) may be present. Say which ones were missing whenever that limits a check or a test.

## Libraries
Published to Maven Central, so they can have any number of consumers, in the owner's application repos and outside. Only dependencies between the libraries themselves are tracked here and in the libraries' `CLAUDE.md` files; applications that use a library are not listed.

| Repo | Depends on (owner's libraries) |
|---|---|
| [ishtech-i18n-java](https://github.com/ishtech/ishtech-i18n-java) | none |
| [ishtech-base-jpa](https://github.com/ishtech/ishtech-base-jpa) | ishtech-i18n-java |
| [ishtech-springboot-jwtauth](https://github.com/ishtech/ishtech-springboot-jwtauth) (also an application: `-lib` and `-api` are published libraries, `-web` is the runnable application) | ishtech-base-jpa (and it pins the `ishtech-i18n` version in its dependency management) |
| [ishtech-validations-java](https://github.com/ishtech/ishtech-validations-java) | none |
| [hetu-util-java](https://github.com/ishtech/hetu-util-java) | none |
| [hetu-validation-java](https://github.com/ishtech/hetu-validation-java) | hetu-util-java |

Dependency tree (each library is listed above the libraries that depend on it):
```
ishtech-i18n-java
└── ishtech-base-jpa
    └── ishtech-springboot-jwtauth
ishtech-validations-java
hetu-util-java
└── hetu-validation-java
```

## Applications
Each application's `.claude/CLAUDE.md` lists the owner's libraries it uses.

| Repo | Build |
|---|---|
| [springboot-books-app](https://github.com/muneer2ishtech/springboot-books-app) | Gradle |
| [springboot-multi-db](https://github.com/muneer2ishtech/springboot-multi-db) | Maven |
| [springboot-multi-port](https://github.com/muneer2ishtech/springboot-multi-port) | Maven |
| [springboot-oms](https://github.com/muneer2ishtech/springboot-oms) | Maven |

All libraries are built with Maven.

## Order of work across repos
The build files (`pom.xml`, `build.gradle.kts`) are the source of truth for dependencies. If this file or a `CLAUDE.md` disagrees with them, follow the build files and update the Claude files.

When a task changes several repos:
- Upstream first: change, build and test a library before the libraries and applications that use it (`build-and-test.md`, section "Cross-repo builds").
- Repos with no dependency path between them are independent. Their changes and tests can be done in parallel or in any order: for example `ishtech-validations-java` and `ishtech-base-jpa`, or anything in the `hetu-*` chain and anything in the `ishtech-*` chain.
- Pushes and publishing of upstream SNAPSHOTs also go upstream first, one repo at a time (`versions-and-releases.md`, section "Publishing upstream SNAPSHOTs before Level 3").
