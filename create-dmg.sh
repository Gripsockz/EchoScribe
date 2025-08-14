#!/bin/bash

# EchoScribe 3.0 - Create DMG Package
echo "📦 EchoScribe 3.0 - Creating DMG Package"
echo "========================================"

# Set variables
APP_NAME="EchoScribe.app"
DMG_NAME="EchoScribe-3.0.dmg"
VOLUME_NAME="EchoScribe 3.0"
BUILD_DIR="build"

# Check if app exists
if [ ! -d "/Applications/${APP_NAME}" ]; then
    echo "❌ Error: ${APP_NAME} not found in Applications"
    echo "Please run build-and-package.sh first"
    exit 1
fi

# Create DMG
echo "🔨 Creating DMG package..."

# Remove existing DMG
if [ -f "${DMG_NAME}" ]; then
    rm "${DMG_NAME}"
fi

# Create DMG
hdiutil create -volname "${VOLUME_NAME}" -srcfolder "/Applications/${APP_NAME}" -ov -format UDZO "${DMG_NAME}"

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 DMG Package Created Successfully!"
    echo "===================================="
    echo "📦 DMG File: ${DMG_NAME}"
    echo "📱 App: ${APP_NAME}"
    echo "📊 Size: $(du -h "${DMG_NAME}" | cut -f1)"
    echo ""
    echo "📋 Distribution ready!"
    echo "   - Share the DMG file"
    echo "   - Users can drag to Applications"
    echo "   - No installation required"
else
    echo "❌ Failed to create DMG package"
    exit 1
fi
