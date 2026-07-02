#!/bin/bash
set -e

PROJECT="MarysRosary.xcodeproj/project.pbxproj"
ARCHIVE_PATH="build/MarysRosary.xcarchive"

# Read current build number and increment
CURRENT=$(grep "CURRENT_PROJECT_VERSION" "$PROJECT" | head -1 | grep -o '[0-9]*')
NEXT=$((CURRENT + 1))

echo "Bumping build number: $CURRENT → $NEXT"
sed -i '' "s/CURRENT_PROJECT_VERSION = $CURRENT;/CURRENT_PROJECT_VERSION = $NEXT;/g" "$PROJECT"

# Archive
echo "Archiving..."
xcodebuild archive \
  -scheme MarysRosary \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE_PATH" \
  | grep -E "error:|warning:|ARCHIVE|BUILD" | grep -v "^$"

echo "✓ Archive complete — build $NEXT"
echo "Opening Organizer..."
open -a Xcode "$ARCHIVE_PATH"

# Commit build number bump
git add "$PROJECT"
git commit -m "Bump build number to $NEXT"
git push
