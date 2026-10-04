#!/bin/bash
# Tests the wait time handling in .github/workflows/cicd.yml, step "Publish to Maven Central Sonatype".
# Runs the step's script, read from the workflow file, with a stub for ./mvnw that prints its arguments
# instead of deploying. CENTRAL_PUBLISHING_WAIT_MAX_TIME is the value the step gets from the input
# central_publishing_wait_max_time or the repository variable CENTRAL_PUBLISHING_WAIT_MAX_TIME.
# Usage, from the repo root: bash .claude/tests/cicd-publish-wait-max-time-test.sh
# Needs bash and awk. Exits with 1 if any case gives an unexpected result.

set -u
REPO_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
WORKFLOW="$REPO_ROOT/.github/workflows/cicd.yml"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# Extract the run script of the step "Publish to Maven Central Sonatype" (indented 10 spaces in the workflow)
awk '
  /name: Publish to Maven Central Sonatype/ { in_step = 1; next }
  in_step && /^ *run: \|/ { in_run = 1; next }
  in_run && /^          / { print substr($0, 11); next }
  in_run && /^ *$/        { print ""; next }
  in_run                  { exit }
' "$WORKFLOW" > "$TMP/publish.sh"
if ! grep -q "central-publishing" "$TMP/publish.sh"; then
  echo "Could not extract the step 'Publish to Maven Central Sonatype' from $WORKFLOW"
  exit 1
fi

printf '#!/bin/bash\necho "mvnw $*"\n' > "$TMP/mvnw"
chmod +x "$TMP/mvnw"
cd "$TMP"

DEPLOY="mvnw -B deploy -DskipTests=true -P gpg -P central-publishing"
PASSED=0
FAILED=0

# run <case> <wait max time value> <expected: deploy command, or FAIL>
run() {
  local name=$1 value=$2 expected=$3 out result
  out=$(CENTRAL_PUBLISHING_WAIT_MAX_TIME="$value" MAVEN_CLI_OPTS="-B" bash -e "$TMP/publish.sh" 2>&1 | tail -1)
  result=$out
  [[ "$out" == *"ERROR:"* ]] && result=FAIL
  if [[ "$result" == "$expected" ]]; then
    PASSED=$((PASSED + 1)); printf 'ok     %-24s %s\n' "$name" "$out"
  else
    FAILED=$((FAILED + 1)); printf 'WRONG  %-24s %s (expected %s)\n' "$name" "$out" "$expected"
  fi
}

echo "--- Not set: plugin default (1800 seconds)"
run "empty"                ""       "$DEPLOY"

echo "--- Whole number above 1800: passed as -DwaitMaxTime"
run "1801"                 "1801"   "$DEPLOY -DwaitMaxTime=1801"
run "3600"                 "3600"   "$DEPLOY -DwaitMaxTime=3600"
run "5400"                 "5400"   "$DEPLOY -DwaitMaxTime=5400"

echo "--- Anything else: the step fails before deploying"
run "1800 (not above)"     "1800"   FAIL
run "1000"                 "1000"   FAIL
run "5400.5 (decimal)"     "5400.5" FAIL
run "5400.0 (decimal)"     "5400.0" FAIL
run "-5 (negative)"        "-5"     FAIL
run "abc (not a number)"   "abc"    FAIL

echo "--- $PASSED passed, $FAILED wrong"
[[ $FAILED -eq 0 ]]
