#!/usr/bin/env bash
#
# Generate App Store screenshots for CheckoutHero.
#
#   ./scripts/screenshots.sh            # iPhone 6.9" + 6.3" + iPad 13", English + Spanish
#   LANGS="en" ./scripts/screenshots.sh # English only
#
# Output: screenshots/<lang>/<device>/NN-name.jpg  (exact App Store sizes, no alpha)
#
set -euo pipefail

cd "$(dirname "$0")/.."
ROOT="$(pwd)"
OUT="$ROOT/screenshots"
LANGS="${LANGS:-en es}"

# App Store Connect display sizes -> simulator model to use
DEVICES=(
  "iPhone-6.9|iPhone 17 Pro Max"
  "iPhone-6.3|iPhone 17 Pro"
  "iPad-13|iPad Pro 13-inch (M5)"
)

udid_for() {
  # Newest runtime that has a simulator with this exact name
  xcrun simctl list devices available -j | python3 -I -c '
import json, sys
name = sys.argv[1]
runtimes = json.load(sys.stdin)["devices"]
best = None
for rt, devs in runtimes.items():
    if "iOS" not in rt:
        continue
    version = tuple(int(p) for p in rt.rsplit("iOS-", 1)[1].split("-"))
    for d in devs:
        if d["name"] == name and (best is None or version > best[0]):
            best = (version, d["udid"])
print(best[1] if best else "")
' "$1"
}

rm -rf "$OUT"
for entry in "${DEVICES[@]}"; do
  label="${entry%%|*}"
  model="${entry#*|}"
  udid="$(udid_for "$model")"
  if [[ -z "$udid" ]]; then
    echo "!! No simulator named '$model' (Xcode → Settings → Components)"; exit 1
  fi
  echo "==> $label: $model ($udid)"

  xcrun simctl boot "$udid" 2>/dev/null || true
  xcrun simctl bootstatus "$udid" -b >/dev/null
  # Clean, Apple-style status bar
  xcrun simctl status_bar "$udid" override \
    --time "9:41" --dataNetwork wifi --wifiMode active --wifiBars 3 \
    --cellularMode active --cellularBars 4 --batteryState charged --batteryLevel 100

  for lang in $LANGS; do
    dir="$OUT/$lang/$label"
    mkdir -p "$dir"
    echo "   -> $lang"
    TEST_RUNNER_SCREENSHOTS_DIR="$dir" TEST_RUNNER_SCREENSHOT_LANG="$lang" \
    xcodebuild test \
      -project CheckoutHero.xcodeproj -scheme CheckoutHero \
      -destination "platform=iOS Simulator,id=$udid" \
      -only-testing:CheckoutHeroUITests/ScreenshotTests \
      -quiet 2>&1 | grep -vE "IDELaunchParametersSnapshot|CoreData:" || true

    # App Store Connect rejects images with an alpha channel: convert to JPEG.
    shopt -s nullglob
    pngs=("$dir"/*.png)
    if (( ${#pngs[@]} == 0 )); then
      echo "!! No screenshots produced for $label/$lang"; exit 1
    fi
    for png in "${pngs[@]}"; do
      sips -s format jpeg -s formatOptions 95 "$png" --out "${png%.png}.jpg" >/dev/null
      rm "$png"
    done
  done

  xcrun simctl status_bar "$udid" clear
done

echo
echo "Screenshots:"
find "$OUT" -name '*.jpg' | sort | while read -r f; do
  printf '  %-55s %s\n' "${f#$ROOT/}" "$(sips -g pixelWidth -g pixelHeight "$f" | awk '/pixel/{printf "%s ", $2}')"
done
