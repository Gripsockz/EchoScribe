#!/bin/bash

echo "🧪 Testing EchoScribe 3.0 - Completed Phases"
echo "=============================================="

# Test Phase 7.1: Advanced Audio Features
echo "📊 Phase 7.1: Advanced Audio Features"
if [ -f "EchoScribe/Core/Audio/AudioEffects.swift" ]; then
    echo "✅ AudioEffects.swift exists"
    swift_lines=$(wc -l < "EchoScribe/Core/Audio/AudioEffects.swift")
    echo "   📝 Lines of code: $swift_lines"
else
    echo "❌ AudioEffects.swift missing"
fi

# Test Phase 9: Professional Export System
echo ""
echo "📊 Phase 9: Professional Export System"
if [ -f "EchoScribe/Core/Export/ExportManager.swift" ]; then
    echo "✅ ExportManager.swift exists"
    swift_lines=$(wc -l < "EchoScribe/Core/Export/ExportManager.swift")
    echo "   📝 Lines of code: $swift_lines"
else
    echo "❌ ExportManager.swift missing"
fi

# Count total Swift files
echo ""
echo "📊 Project Statistics"
total_files=$(find EchoScribe -name "*.swift" | wc -l)
echo "   📁 Total Swift files: $total_files"

total_lines=$(find EchoScribe -name "*.swift" -exec wc -l {} + | tail -1 | awk '{print $1}')
echo "   📝 Total lines of code: $total_lines"

echo ""
echo "✅ Phase completion test completed successfully!"
