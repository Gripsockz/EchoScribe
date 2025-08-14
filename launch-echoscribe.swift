#!/usr/bin/env swift

import Foundation
import SwiftUI

// Simple launcher for EchoScribe
print("🚀 Launching EchoScribe 3.0...")
print("📁 Project Directory: \(FileManager.default.currentDirectoryPath)")
print("📊 Swift Files Found: \(countSwiftFiles())")

func countSwiftFiles() -> Int {
    let fileManager = FileManager.default
    let currentPath = fileManager.currentDirectoryPath
    let echoScribePath = "\(currentPath)/EchoScribe"
    
    guard let enumerator = fileManager.enumerator(atPath: echoScribePath) else {
        return 0
    }
    
    var count = 0
    while let file = enumerator.nextObject() as? String {
        if file.hasSuffix(".swift") {
            count += 1
        }
    }
    return count
}

// Check if we can find the main app file
let mainAppPath = "EchoScribe/App/EchoScribeApp.swift"
if FileManager.default.fileExists(atPath: mainAppPath) {
    print("✅ Found main app file: \(mainAppPath)")
} else {
    print("❌ Main app file not found: \(mainAppPath)")
}

print("🎯 EchoScribe 3.0 is ready to launch!")
print("📋 To launch the app, you can:")
print("   1. Open EchoScribe.xcodeproj in Xcode")
print("   2. Press Cmd+R to build and run")
print("   3. Or use: open EchoScribe.xcodeproj")
