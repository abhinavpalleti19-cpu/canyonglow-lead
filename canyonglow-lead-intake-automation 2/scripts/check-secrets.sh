#!/usr/bin/env bash
# Scan the repo for likely secrets before committing.
PATTERN='(sk-or-[A-Za-z0-9_-]{10,}|sk-[A-Za-z0-9]{20,}|apify_api_[A-Za-z0-9]+|ya29\.[A-Za-z0-9_-]+|AIza[0-9A-Za-z_-]{20}|xox[bp]-[A-Za-z0-9-]+|Bearer [A-Za-z0-9._-]{20,}|client_secret|refresh_token|private_key)'
if grep -rEn --exclude-dir=.git --exclude=check-secrets.sh "$PATTERN" .; then
  echo "Possible secrets found. Fix before committing."; exit 1
else
  echo "No obvious secrets found."
fi
