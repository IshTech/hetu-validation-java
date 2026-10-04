#!/bin/bash
# Tests the deploy rules in .github/workflows/cicd.yml, step "Validate Project Version".
# Runs the step's script, read from the workflow file, against a mock git repository,
# with stubs for ./mvnw (prints the pom version) and gh (prints the number of successful release runs).
# Usage, from the repo root: bash .claude/tests/cicd-validate-project-version-test.sh
# Needs bash, git and awk. Exits with 1 if any case gives an unexpected result.

set -u
REPO_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
WORKFLOW="$REPO_ROOT/.github/workflows/cicd.yml"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# Extract the run script of the step with id validate-project-version (indented 10 spaces in the workflow)
awk '
  /id: validate-project-version/ { in_step = 1; next }
  in_step && /^ *run: \|/        { in_run = 1; next }
  in_run && /^          / { print substr($0, 11); next }
  in_run && /^ *$/        { print ""; next }
  in_run                  { exit }
' "$WORKFLOW" > "$TMP/validate.sh"
if ! grep -q "do_release" "$TMP/validate.sh"; then
  echo "Could not extract the step 'Validate Project Version' from $WORKFLOW"
  exit 1
fi

mkdir -p "$TMP/bin"
printf '#!/bin/bash\necho "$GH_COUNT"\n' > "$TMP/bin/gh"
chmod +x "$TMP/bin/gh"

# Mock origin:
#   main:      r1 (tag v1.0.0) -> r2 (tag v1.1.0)
#   dev-jdk21: r1 -> j (tag v1.0.0-jdk21)
#   dev-jdk17: r1
#   feat:      r2 -> f (tags v9.9.9, v1.1.0-jdk21x)
(
  set -e
  export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com
  git init -q "$TMP/origin" && cd "$TMP/origin"
  git checkout -q -b main
  git commit -q --allow-empty -m r1 && git tag v1.0.0
  git branch dev-jdk17
  git checkout -q -b dev-jdk21 && git commit -q --allow-empty -m j && git tag v1.0.0-jdk21
  git checkout -q main && git commit -q --allow-empty -m r2 && git tag v1.1.0
  git checkout -q -b feat && git commit -q --allow-empty -m f && git tag v9.9.9 && git tag v1.1.0-jdk21x
  git checkout -q main
  git clone -q "$TMP/origin" "$TMP/work"
) || { echo "Could not create the mock repository"; exit 1; }
cd "$TMP/work"

PASSED=0
FAILED=0

# run <case> <expected: DEPLOY|BUILD|FAIL> <event> <ref type> <ref name> <commit> <pom version> [manual_deploy] [release tag] [successful release runs]
run() {
  local name=$1 expected=$2 out result
  printf '#!/bin/bash\necho %s\n' "$7" > mvnw
  out=$(PATH="$TMP/bin:$PATH" \
    GITHUB_EVENT_NAME=$3 GITHUB_REF_TYPE=$4 GITHUB_REF_NAME=$5 GITHUB_SHA=$(git rev-parse "$6^{commit}") \
    MANUAL_DEPLOY=${8:-} RELEASE_TAG=${9:-} GH_COUNT=${10:-1} GITHUB_REPOSITORY=owner/repo GITHUB_OUTPUT=/dev/null \
    bash -e "$TMP/validate.sh" 2>&1 | tail -1)
  result=FAIL
  [[ "$out" == *do_release=true* ]] && result=DEPLOY
  [[ "$out" == *do_release=false* ]] && result=BUILD
  if [[ "$result" == "$expected" ]]; then
    PASSED=$((PASSED + 1)); printf 'ok     %-38s %-6s %s\n' "$name" "$result" "$out"
  else
    FAILED=$((FAILED + 1)); printf 'WRONG  %-38s %-6s (expected %s) %s\n' "$name" "$result" "$expected" "$out"
  fi
}

M=origin/main
echo "--- GitHub release: vx.y.z on main only"
run "release v1.0.0 on main"             DEPLOY release tag v1.0.0       v1.0.0       1.0.0                "" v1.0.0
run "release, tag does not match pom"    FAIL   release tag v1.0.0       v1.0.0       1.0.1                "" v1.0.0
run "release from a branch, not main"    FAIL   release tag v9.9.9       v9.9.9       9.9.9                "" v9.9.9
run "release, SNAPSHOT version"          FAIL   release tag v1.0.0       v1.0.0       1.0.0-SNAPSHOT       "" v1.0.0
run "release with a jdk tag"             FAIL   release tag v1.0.0-jdk21 v1.0.0-jdk21 1.0.0-jdk21          "" v1.0.0-jdk21

echo "--- Tag push: vx.y.z-jdkMN on dev-jdkMN"
run "tag v1.0.0-jdk21 on dev-jdk21"      DEPLOY push tag v1.0.0-jdk21  v1.0.0-jdk21 1.0.0-jdk21          "" "" 1
run "tag, release v1.0.0 run not green"  FAIL   push tag v1.0.0-jdk21  v1.0.0-jdk21 1.0.0-jdk21          "" "" 0
run "tag jdk17 on dev-jdk21 commit"      FAIL   push tag v1.0.0-jdk17  v1.0.0-jdk21 1.0.0-jdk17          "" "" 1
run "tag, release tag v1.2.0 missing"    FAIL   push tag v1.2.0-jdk21  v1.0.0-jdk21 1.2.0-jdk21          "" "" 1
run "tag, release v1.1.0 not merged"     FAIL   push tag v1.1.0-jdk21  v1.0.0-jdk21 1.1.0-jdk21          "" "" 1
run "tag does not match pom"             FAIL   push tag v1.0.1-jdk21  v1.0.0-jdk21 1.0.0-jdk21          "" "" 1
run "tag, SNAPSHOT version"              FAIL   push tag v1.0.0-jdk21  v1.0.0-jdk21 1.0.0-jdk21-SNAPSHOT "" "" 1
run "tag v1.1.0-jdk21x (bad suffix)"     FAIL   push tag v1.1.0-jdk21x v1.1.0-jdk21x 1.1.0-jdk21x        "" "" 1

echo "--- Manual run from a tag"
run "from a tag, manual_deploy=true"     FAIL   workflow_dispatch tag v1.0.0 v1.0.0 1.0.0 true
run "from a tag, manual_deploy=false"    BUILD  workflow_dispatch tag v1.0.0 v1.0.0 1.0.0 false

echo "--- main"
run "push main, x.y.z"                   BUILD  push              branch main $M 1.1.0
run "push main, SNAPSHOT"                FAIL   push              branch main $M 1.2.0-SNAPSHOT
run "push main, x.y.z-jdk21"             FAIL   push              branch main $M 1.1.0-jdk21
run "main, manual_deploy=true"           FAIL   workflow_dispatch branch main $M 1.1.0 true

echo "--- Pushes and manual runs on other branches"
run "push dev, SNAPSHOT"                 BUILD  push              branch dev       $M 1.2.0-SNAPSHOT
run "push dev, release version"          FAIL   push              branch dev       $M 1.2.0
run "push feature, plain SNAPSHOT"       BUILD  push              branch feature/x $M 1.2.0-SNAPSHOT
run "feature, manual_deploy=false"       BUILD  workflow_dispatch branch feature/x $M 1.2.0-SNAPSHOT false

echo "--- Manual deploy (manual_deploy=true) on other branches"
run "dev, x.y.z-SNAPSHOT"                DEPLOY workflow_dispatch branch dev       $M 1.2.0-SNAPSHOT              true
run "dev, with a qualifier"              FAIL   workflow_dispatch branch dev       $M 1.2.0-foo-SNAPSHOT          true
run "dev-jdk21, x.y.z-jdk21-SNAPSHOT"    DEPLOY workflow_dispatch branch dev-jdk21 $M 1.2.0-jdk21-SNAPSHOT        true
run "dev-jdk21, x.y.z-jdk17-SNAPSHOT"    FAIL   workflow_dispatch branch dev-jdk21 $M 1.2.0-jdk17-SNAPSHOT        true
run "dev-jdk21, x.y.z-SNAPSHOT"          FAIL   workflow_dispatch branch dev-jdk21 $M 1.2.0-SNAPSHOT              true
run "feature, isactive_fix qualifier"    DEPLOY workflow_dispatch branch feature/x $M 1.2.0-isactive_fix-SNAPSHOT true
run "feature, issue4 qualifier"          DEPLOY workflow_dispatch branch feature/x $M 1.2.0-issue4-SNAPSHOT       true
run "feature, no qualifier"              FAIL   workflow_dispatch branch feature/x $M 1.2.0-SNAPSHOT              true
run "feature, jdk21 qualifier"           FAIL   workflow_dispatch branch feature/x $M 1.2.0-jdk21-SNAPSHOT        true
run "feature, issue4-jdk21 qualifier"    FAIL   workflow_dispatch branch feature/x $M 1.2.0-issue4-jdk21-SNAPSHOT true
run "feature, qualifier with a dot"      FAIL   workflow_dispatch branch feature/x $M 1.2.0-a.b-SNAPSHOT          true

echo "--- $PASSED passed, $FAILED wrong"
[[ $FAILED -eq 0 ]]
