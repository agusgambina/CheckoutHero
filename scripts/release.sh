#!/usr/bin/env bash
#
# Build, upload and (optionally) submit CheckoutHero to App Review.
#
#   ./scripts/release.sh                     # dry run: checks + read-only App Store Connect lookups
#   ./scripts/release.sh --upload            # bump build, test, archive, upload, attach to version
#   ./scripts/release.sh --upload --submit   # ...and submit the version for review
#   ./scripts/release.sh --submit            # submit the version with the build already attached
#
# Needs an App Store Connect API key (App Manager role):
#   export ASC_KEY_ID=XXXXXXXXXX ASC_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
#   key file at ~/.appstoreconnect/private_keys/AuthKey_$ASC_KEY_ID.p8 (or set ASC_KEY_PATH)
#
# Optional:
#   REVIEW_NOTES=path/to/notes.txt   App Review notes to set on the version
#   SKIP_TESTS=1                     skip the unit + UI test run before archiving
#   ALLOW_BRANCH=1                   allow releasing from a branch other than main
#
set -euo pipefail

cd "$(dirname "$0")/.."
ROOT="$(pwd)"
PROJECT="CheckoutHero.xcodeproj"
SCHEME="CheckoutHero"
BUNDLE_ID="littlebit.CheckoutHero"
TEAM_ID="296P7R7T9M"
TEST_DEVICE="iPhone 17 Pro Max"
OUT="$ROOT/build/release"

UPLOAD=0
SUBMIT=0
for arg in "$@"; do
  case "$arg" in
    --upload) UPLOAD=1 ;;
    --submit) SUBMIT=1 ;;
    -h|--help) sed -n '2,19p' "$0"; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

# System Python by default: some pyenv builds print hashlib (blake2) errors on every import.
PYTHON="${PYTHON:-/usr/bin/python3}"
asc() { "$PYTHON" -I "$ROOT/scripts/asc.py" "$@"; }
step() { printf '\n==> %s\n' "$*"; }
setting() {
  # Resolved Release value of a build setting for the app target.
  xcodebuild -showBuildSettings -project "$PROJECT" -target "$SCHEME" -configuration Release \
    2>/dev/null | awk -v key="$1" '$1 == key && $2 == "=" { print $3; exit }'
}

# --- Preflight -----------------------------------------------------------------------------
step "Preflight"
: "${ASC_KEY_ID:?set ASC_KEY_ID}" "${ASC_ISSUER_ID:?set ASC_ISSUER_ID}"
ASC_KEY_PATH="${ASC_KEY_PATH:-$HOME/.appstoreconnect/private_keys/AuthKey_$ASC_KEY_ID.p8}"
export ASC_KEY_PATH
[[ -f "$ASC_KEY_PATH" ]] || { echo "API key not found: $ASC_KEY_PATH" >&2; exit 1; }

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$BRANCH" != "main" && "${ALLOW_BRANCH:-0}" != "1" ]]; then
  echo "On '$BRANCH'; release from main (or set ALLOW_BRANCH=1)." >&2; exit 1
fi
if [[ -n "$(git status --porcelain)" ]]; then
  echo "Working tree is not clean; commit or move the changes first." >&2; exit 1
fi

VERSION="$(setting MARKETING_VERSION)"
LOCAL_BUILD="$(setting CURRENT_PROJECT_VERSION)"
echo "Version $VERSION, local build $LOCAL_BUILD, branch $BRANCH @ $(git rev-parse --short HEAD)"

# The 2.1(b) rejection: a free app must not ship purchase UI or StoreKit.
if grep -rqE "import StoreKit|Product\.products" --include='*.swift' "$ROOT/CheckoutHero"; then
  echo "StoreKit code found in CheckoutHero/; remove it or attach the IAPs to the version." >&2
  exit 1
fi

# --- App Store Connect lookups (read-only) -------------------------------------------------
step "App Store Connect"
APP_ID="$(asc app-id "$BUNDLE_ID")"
VERSION_INFO="$(asc version "$APP_ID" "$VERSION")"
read -r VERSION_ID VERSION_STATE <<< "$VERSION_INFO"
echo "App $APP_ID, version $VERSION is $VERSION_STATE ($VERSION_ID)"

IAPS="$(asc list-iap "$APP_ID")"
if [[ -n "$IAPS" ]]; then
  echo "In-app purchases still defined (detach or remove them in App Store Connect):"
  echo "$IAPS" | sed 's/^/  /'
fi

if [[ "$UPLOAD" == "0" && "$SUBMIT" == "0" ]]; then
  echo
  echo "Dry run done. Next: --upload to build and attach, --submit to send for review."
  exit 0
fi

# --- Build, test, archive, upload ----------------------------------------------------------
if [[ "$UPLOAD" == "1" ]]; then
  BUILD="$(asc next-build "$APP_ID" "$VERSION" "$LOCAL_BUILD")"
  step "Build number $LOCAL_BUILD -> $BUILD"
  # Only the app target's configs carry the current local build number.
  sed -i '' -E "s/CURRENT_PROJECT_VERSION = $LOCAL_BUILD;/CURRENT_PROJECT_VERSION = $BUILD;/" \
    "$PROJECT/project.pbxproj"

  AUTH=(-allowProvisioningUpdates
        -authenticationKeyPath "$ASC_KEY_PATH"
        -authenticationKeyID "$ASC_KEY_ID"
        -authenticationKeyIssuerID "$ASC_ISSUER_ID")

  if [[ "${SKIP_TESTS:-0}" != "1" ]]; then
    step "Tests on $TEST_DEVICE"
    xcodebuild test -project "$PROJECT" -scheme "$SCHEME" \
      -destination "platform=iOS Simulator,name=$TEST_DEVICE" -quiet
  fi

  step "Archive"
  rm -rf "$OUT"; mkdir -p "$OUT"
  xcodebuild archive -project "$PROJECT" -scheme "$SCHEME" -configuration Release \
    -destination 'generic/platform=iOS' -archivePath "$OUT/$SCHEME.xcarchive" \
    "${AUTH[@]}" -quiet

  step "Upload"
  cat > "$OUT/ExportOptions.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key><string>app-store-connect</string>
  <key>destination</key><string>upload</string>
  <key>teamID</key><string>$TEAM_ID</string>
  <key>signingStyle</key><string>automatic</string>
  <key>manageAppVersionAndBuildNumber</key><false/>
  <key>uploadSymbols</key><true/>
</dict>
</plist>
PLIST
  xcodebuild -exportArchive -archivePath "$OUT/$SCHEME.xcarchive" \
    -exportOptionsPlist "$OUT/ExportOptions.plist" -exportPath "$OUT/export" "${AUTH[@]}"

  step "Waiting for build $BUILD to process"
  BUILD_ID="$(asc wait-build "$APP_ID" "$VERSION" "$BUILD")"

  step "Attach build $BUILD to version $VERSION"
  asc attach-build "$VERSION_ID" "$BUILD_ID"

  echo "Build number changed in $PROJECT; commit it: git commit -am \"Build $VERSION ($BUILD)\""
fi

if [[ -n "${REVIEW_NOTES:-}" ]]; then
  step "Review notes"
  asc set-notes "$VERSION_ID" "$REVIEW_NOTES"
fi

# --- Submit --------------------------------------------------------------------------------
if [[ "$SUBMIT" == "1" ]]; then
  step "Submit version $VERSION for review"
  if [[ -n "$IAPS" ]]; then
    echo "Note: in-app purchases listed above still exist; make sure none is attached." >&2
  fi
  asc submit "$APP_ID" "$VERSION_ID"
fi

echo
echo "Done."
