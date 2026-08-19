#!/usr/bin/env bash
# Self-check for the image-age (Debian package refresh) rebuild decision.
#
# Replays the auto-check branch of "Determine build versions" with a stubbed
# `crane config` so no registry is touched. The rule under test: with no upstream
# version change, rebuild anyway once the published image reaches MAX_IMAGE_AGE_DAYS,
# and do not let the tag-exists check veto that rebuild.
set -uo pipefail
fail() { echo "FAIL: $*"; exit 1; }

# $1 = age of :latest in days ("none" = unreadable), $2 = ffmpeg changed?, $3 = tag exists?
# Threshold and enable flag come from CP_*/VAR_* env, mirroring the workflow.
decide() {
  local age=$1 version_changed=$2 tag_exists=$3
  local SHOULD_BUILD="false" STALE_REBUILD="false"

  [[ "$version_changed" == "true" ]] && SHOULD_BUILD="true"

  # Same precedence chain as the workflow: client_payload > repo var > default.
  local PACKAGE_REFRESH MAX_IMAGE_AGE_DAYS
  PACKAGE_REFRESH="${CP_PACKAGE_REFRESH:-${VAR_PACKAGE_REFRESH:-true}}"
  MAX_IMAGE_AGE_DAYS="${CP_MAX_IMAGE_AGE_DAYS:-${VAR_MAX_IMAGE_AGE_DAYS:-30}}"

  if [[ "$SHOULD_BUILD" != "true" && "$PACKAGE_REFRESH" == "true" && "$MAX_IMAGE_AGE_DAYS" != "0" ]]; then
    local CREATED=""
    [[ "$age" != "none" ]] && CREATED=$(date -u -d "${age} days ago" +%Y-%m-%dT%H:%M:%SZ)
    if [[ -n "$CREATED" ]]; then
      local CREATED_EPOCH AGE_DAYS
      CREATED_EPOCH=$(date -d "$CREATED" +%s 2>/dev/null || echo 0)
      if [[ "$CREATED_EPOCH" -gt 0 ]]; then
        AGE_DAYS=$(( ( $(date +%s) - CREATED_EPOCH ) / 86400 ))
        if [[ "$AGE_DAYS" -ge "${MAX_IMAGE_AGE_DAYS}" ]]; then
          SHOULD_BUILD="true"; STALE_REBUILD="true"
        fi
      fi
    fi
  fi

  # Final build decision: the tag-exists veto, which must not fire on a refresh.
  local FINAL="$SHOULD_BUILD"
  if [[ "$SHOULD_BUILD" == "true" && "$tag_exists" == "true" \
        && "$STALE_REBUILD" != "true" ]]; then
    FINAL="false"
  fi
  echo "$FINAL $STALE_REBUILD"
}

echo "== fresh image, no upstream change =="
read -r build stale <<< "$(decide 5 false true)"
[ "$build" = "false" ] || fail "rebuilt a 5-day-old image (build=$build)"
echo "  no rebuild (build=$build stale=$stale)"

echo "== 29 days: still inside the window =="
read -r build stale <<< "$(decide 29 false true)"
[ "$build" = "false" ] || fail "rebuilt at 29d, threshold is 30d"
echo "  no rebuild"

echo "== 30 days: threshold reached =="
read -r build stale <<< "$(decide 30 false true)"
[ "$build" = "true" ] || fail "no rebuild at exactly 30d"
[ "$stale" = "true" ] || fail "stale_rebuild flag not set"
echo "  rebuilds despite the tag already existing"

echo "== 75 days: a long real-world gap =="
read -r build stale <<< "$(decide 75 false true)"
[ "$build" = "true" ] || fail "no rebuild after 75d -- a months-long package gap would recur"
echo "  rebuilds"

echo "== upstream change wins, and is not marked stale =="
read -r build stale <<< "$(decide 1 true false)"
[ "$build" = "true" ] || fail "upstream change did not build"
[ "$stale" = "false" ] || fail "upstream build wrongly flagged as a package refresh"
echo "  normal version build, stale flag clear"

echo "== tag-exists veto still applies to a non-stale build =="
read -r build stale <<< "$(decide 1 true true)"
[ "$build" = "false" ] || fail "existing tag was rebuilt without the stale flag"
echo "  veto intact"

echo "== disabled via repo var MAX_IMAGE_AGE_DAYS=0 =="
read -r build stale <<< "$(VAR_MAX_IMAGE_AGE_DAYS=0 decide 400 false true)"
[ "$build" = "false" ] || fail "age check ran while disabled"
echo "  no rebuild"

echo "== disabled via dispatch payload package_refresh=false =="
read -r build stale <<< "$(CP_PACKAGE_REFRESH=false decide 400 false true)"
[ "$build" = "false" ] || fail "dispatch payload false was ignored -- the GitHub-expression trap"
echo "  no rebuild"

echo "== dispatch payload package_refresh=true overrides a repo var of false =="
read -r build stale <<< "$(CP_PACKAGE_REFRESH=true VAR_PACKAGE_REFRESH=false decide 40 false true)"
[ "$build" = "true" ] || fail "client_payload did not win over the repo var"
echo "  rebuilds"

echo "== dispatch payload max_image_age_days=14 tightens the window =="
read -r build stale <<< "$(CP_MAX_IMAGE_AGE_DAYS=14 decide 20 false true)"
[ "$build" = "true" ] || fail "20d image not rebuilt under a 14d threshold"
read -r build stale <<< "$(CP_MAX_IMAGE_AGE_DAYS=14 decide 10 false true)"
[ "$build" = "false" ] || fail "10d image rebuilt under a 14d threshold"
echo "  honours the payload threshold both ways"

echo "== default is enabled when nothing is configured =="
read -r build stale <<< "$(decide 40 false true)"
[ "$build" = "true" ] || fail "default should be enabled"
echo "  defaults to true"

# The job-level exemption is worthless unless the per-platform existence check
# honours it too -- otherwise every platform build skips and the refresh is a no-op.
platform_skips() { # $1=force_build $2=stale_rebuild $3=tag exists
  if [[ "$1" == "true" || "$2" == "true" ]]; then echo "false"; return; fi
  [[ "$3" == "true" ]] && echo "true" || echo "false"
}
echo "== per-platform existence check honours the refresh =="
[ "$(platform_skips false true true)" = "false" ] || fail "platform build skipped during a package refresh -- refresh would produce nothing"
[ "$(platform_skips true false true)" = "false" ] || fail "force_build did not bypass the platform check"
[ "$(platform_skips false false true)" = "true" ] || fail "platform check no longer skips an existing tag"
[ "$(platform_skips false false false)" = "false" ] || fail "platform build skipped a missing tag"
echo "  refresh builds, normal skip behaviour intact"

echo "== unreadable creation date degrades safely =="
read -r build stale <<< "$(decide none false true)"
[ "$build" = "false" ] || fail "built on an unreadable creation date"
echo "  skipped, no build"

echo "ALL CHECKS PASSED"
