#!/bin/bash
set -e

PROJECT="MarysRosary.xcodeproj/project.pbxproj"
ARCHIVE_PATH="build/MarysRosary.xcarchive"
EXPORT_PATH="build/MarysRosaryExport"
EXPORT_OPTIONS="scripts/ExportOptions.plist"

# Read current build number and increment
CURRENT=$(grep "CURRENT_PROJECT_VERSION" "$PROJECT" | head -1 | grep -o '[0-9]*')
NEXT=$((CURRENT + 1))

echo "▶ Bumping build number: $CURRENT → $NEXT"
sed -i '' "s/CURRENT_PROJECT_VERSION = $CURRENT;/CURRENT_PROJECT_VERSION = $NEXT;/g" "$PROJECT"

# Archive
echo "▶ Archiving..."
xcodebuild archive \
  -scheme MarysRosary \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE_PATH" \
  2>&1 | grep -E "error:|ARCHIVE SUCCEEDED|BUILD FAILED"

echo "✓ Archive complete — build $NEXT"

# Upload to App Store Connect
echo "▶ Uploading to App Store Connect..."
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS" \
  -allowProvisioningUpdates \
  2>&1 | grep -E "error:|EXPORT SUCCEEDED|No errors|Upload|Uploading"

echo "✓ Upload complete — build $NEXT is processing in App Store Connect"

# Commit and push build number bump
git add "$PROJECT"
git commit -m "Bump build number to $NEXT"
git push

echo "✓ Done — build $NEXT"
