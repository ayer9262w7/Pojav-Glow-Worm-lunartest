#!/usr/bin/env bash
set -euo pipefail
UPSTREAM_REPO="https://github.com/NotAHero04/PojavLauncher.git"
UPSTREAM_BRANCH="lunar_test"
PR_BRANCH="local/merge-lunar_test-$(date -u +%Y%m%d-%H%M%S)"

git fetch origin
git checkout -b "${PR_BRANCH}"

git remote add upstream "${UPSTREAM_REPO}" 2>/dev/null || true
git fetch upstream

if git merge --no-edit "upstream/${UPSTREAM_BRANCH}"; then
  echo "Merge succeeded cleanly."
else
  echo "Merge conflicts detected; trying recursive/theirs fallback (may overwrite)."
  git merge -s recursive -X theirs --no-edit "upstream/${UPSTREAM_BRANCH}" || true
fi

# Run build (won't run on GitHub web, đây là file tham khảo nếu bạn dùng local sau này)
if [ -x ./gradlew ]; then
  ./gradlew clean assembleDebug || ./gradlew build || true
else
  echo "No gradlew found; skip build"
fi

echo "Done. If satisfied, push with: git push origin ${PR_BRANCH}"
