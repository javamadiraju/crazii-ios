#!/bin/bash
# Crazii iOS Build Script
# Run from project root: ./scripts/build-ios.sh

set -e

# Add Flutter and CocoaPods to PATH (install locations may vary)
export PATH="${PATH}:${HOME}/flutter/bin:${HOME}/Vendor/ruby/bin"
export GEM_HOME="${HOME}/Vendor/ruby"

# CocoaPods 1.10.2 workaround for GTMSessionFetcher version check (Ruby 2.6 compatibility)
export COCOAPODS_SKIP_VERSION_CHECK=1

echo "Building iOS app for simulator..."
flutter build ios --simulator

echo ""
echo "✓ Build complete: build/ios/iphonesimulator/Runner.app"
echo ""
echo "To run on simulator: flutter run -d ios"
