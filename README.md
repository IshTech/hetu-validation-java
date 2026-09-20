# hetu-validation-java

**Java Validators for Henkil&#246;tunnus (or Finnish Social Security Number)**

In Finland, the personal identity code / personal identification number,  Finnish: henkil&#246;tunnus (HETU), Swedish: personbeteckning, is used for identifying the citizens in many government and civilian systems.

It uses the form DDMMYYCZZZQ, where DDMMYY is the date of birth.

This library provides a Jakarta Validation constraint for that format, built on [hetu-util-java](https://github.com/ishtech/hetu-util-java).

## Usage

- Note: in `pom.xml` / `build.gradle` put required version number

### Maven

```xml
<dependency>
	<groupId>fi.ishtech.hetu</groupId>
	<artifactId>hetu-validation</artifactId>
	<version>${hetu-validation.version}</version>
</dependency>

```

### Gradle

```
implementation("fi.ishtech.hetu:hetu-validation:${hetuValidationVersion}")
```

### Code Samples

#### `@HeTu`

Validates that a value is a henkil&#246;tunnus.

- Supported types: `CharSequence` (for example `String`).
- `null` values are considered valid; use `@NotNull` alongside it if a value is required.
- `mode` (default `CHECKSUM`) selects how strictly the value is checked:

| Mode | Checks |
|---|---|
| `REGEX` | The value is well-formed in the `DDMMYYCZZZQ` format. |
| `DOB` | Everything `REGEX` checks, and that the `DDMMYY` part is a valid calendar date. |
| `CHECKSUM` | Everything `DOB` checks, and that the check character `Q` matches. |

The constraint is repeatable, so several `@HeTu` constraints may be declared on the same element.

Example, on a POJO field:

```java
public class Person {

	@NotNull
	@HeTu
	private String hetu;

	@HeTu(mode = HeTuValidationMode.REGEX)
	private String legacyHetu;

}
```

## Build

This is a library; it **does not run** as a standalone application.

It depends on `hetu-util`. When that dependency is a `-SNAPSHOT` version that is not published, build [hetu-util-java](https://github.com/ishtech/hetu-util-java) first so the snapshot is in the local Maven repository.

### Maven

#### Local Maven Build

- Build without tests

```
./mvnw clean install -DskipTests
```

- Build with Junit tests

```
./mvnw clean install
```

## Deploy to Sonatype Central

```
./mvnw clean deploy -P gpg -P central-publishing
```
