#!/bin/bash

# EchoScribe Build Script
# This script builds the EchoScribe project using Swift Package Manager

set -e

echo "🎯 EchoScribe - Premium macOS Audio Recording & AI Transcription App"
echo "================================================================"

# Check if we're in the right directory
if [ ! -f "project.yml" ]; then
    echo "❌ Error: project.yml not found. Please run this script from the EchoScribe-Premium directory."
    exit 1
fi

# Check for Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode command line tools not found. Please install Xcode."
    exit 1
fi

echo "✅ Xcode command line tools found"

# Create Package.swift if it doesn't exist
if [ ! -f "Package.swift" ]; then
    echo "📦 Creating Package.swift..."
    cat > Package.swift << 'EOF'
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EchoScribe",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "EchoScribe",
            targets: ["EchoScribe"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "EchoScribe",
            dependencies: [],
            path: "EchoScribe",
            sources: [
                "App",
                "Core/Audio",
                "Core/AI", 
                "Core/Database",
                "Core/Export",
                "UI/Views",
                "UI/Components",
                "UI/Styles",
                "UI/Extensions",
                "Models",
                "Utils"
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
EOF
fi

# Create Sources directory structure
echo "📁 Creating source directory structure..."
mkdir -p Sources/EchoScribe

# Copy all Swift files to Sources
echo "📋 Copying source files..."
find EchoScribe -name "*.swift" -exec cp {} Sources/EchoScribe/ \;

# Copy resources
if [ -d "EchoScribe/Resources" ]; then
    echo "📦 Copying resources..."
    cp -r EchoScribe/Resources Sources/EchoScribe/
fi

# Copy Info.plist and entitlements
if [ -f "EchoScribe/App/Info.plist" ]; then
    echo "📄 Copying Info.plist..."
    cp EchoScribe/App/Info.plist Sources/EchoScribe/
fi

if [ -f "EchoScribe/App/entitlements.mac.plist" ]; then
    echo "🔐 Copying entitlements..."
    cp EchoScribe/App/entitlements.mac.plist Sources/EchoScribe/
fi

# Build the project
echo "🔨 Building EchoScribe..."
swift build -c release

echo "✅ Build completed successfully!"
echo ""
echo "🎉 EchoScribe has been built successfully!"
echo ""
echo "📱 To run the app:"
echo "   swift run -c release"
echo ""
echo "📦 To create an app bundle:"
echo "   ./create-app-bundle.sh"
echo ""
echo "🚀 Next steps:"
echo "   1. Test the app functionality"
echo "   2. Add missing UI components"
echo "   3. Implement CoreML integration"
echo "   4. Add comprehensive testing"
echo "   5. Prepare for distribution"
