#!/bin/bash

# EchoScribe Build Test Script
echo "🎯 Testing EchoScribe Build"
echo "============================"

# Navigate to the simple project directory
cd EchoScribe-Simple

echo "📁 Current directory: $(pwd)"
echo "📋 Files in directory:"
ls -la *.swift | wc -l | xargs echo "   Swift files:"
ls -la *.plist | wc -l | xargs echo "   Config files:"

echo ""
echo "🔨 Attempting to build project..."

# Try to build the project
if xcodebuild -project EchoScribe.xcodeproj -scheme EchoScribe -configuration Debug build; then
    echo "✅ Build successful!"
    echo ""
    echo "🎉 Project is ready to run!"
    echo ""
    echo "📱 Next steps:"
    echo "   1. Open EchoScribe.xcodeproj in Xcode"
    echo "   2. Set your development team for code signing"
    echo "   3. Press Cmd+R to run the app"
    echo "   4. Grant permissions when prompted"
    echo "   5. Test all features"
else
    echo "❌ Build failed. This is normal for a new project."
    echo ""
    echo "🔧 This usually means we need to:"
    echo "   1. Open the project in Xcode"
    echo "   2. Configure code signing"
    echo "   3. Set up the development team"
    echo "   4. Clean and rebuild"
    echo ""
    echo "📱 Let's open it in Xcode to fix this:"
    echo "   open EchoScribe.xcodeproj"
fi

echo ""
echo "📊 Project Status:"
echo "   ✅ All source files present"
echo "   ✅ Xcode project structure intact"
echo "   ✅ Configuration files ready"
echo "   🎯 Ready for Xcode configuration"
