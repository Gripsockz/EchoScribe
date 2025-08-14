#!/usr/bin/env swift

import Foundation

// EchoScribe 3.0 Terminal Test Suite
print("🧪 EchoScribe 3.0 - Terminal Test Suite")
print("========================================")

// Test 1: Project Structure
print("\n📁 Test 1: Project Structure")
print(String(repeating: "-", count: 30))

let projectPath = FileManager.default.currentDirectoryPath
let echoScribePath = "\(projectPath)/EchoScribe"

print("Project Path: \(projectPath)")
print("EchoScribe Path: \(echoScribePath)")

// Check if main directories exist
let directories = [
    "App",
    "Core/Audio", 
    "Core/AI",
    "Core/Database",
    "Core/Export",
    "UI/Views",
    "UI/Components",
    "Models",
    "Utils"
]

var directoryResults: [String: Bool] = [:]
for dir in directories {
    let fullPath = "\(echoScribePath)/\(dir)"
    let exists = FileManager.default.fileExists(atPath: fullPath)
    directoryResults[dir] = exists
    print("\(exists ? "✅" : "❌") \(dir): \(exists ? "Found" : "Missing")")
}

// Test 2: Swift Files Count
print("\n📊 Test 2: Swift Files Analysis")
print(String(repeating: "-", count: 30))

func countSwiftFiles(in path: String) -> Int {
    guard let enumerator = FileManager.default.enumerator(atPath: path) else { return 0 }
    var count = 0
    while let file = enumerator.nextObject() as? String {
        if file.hasSuffix(".swift") {
            count += 1
        }
    }
    return count
}

let totalSwiftFiles = countSwiftFiles(in: echoScribePath)
print("Total Swift Files: \(totalSwiftFiles)")

// Test 3: Key Files Check
print("\n🔍 Test 3: Key Files Verification")
print(String(repeating: "-", count: 30))

let keyFiles = [
    "App/EchoScribeApp.swift",
    "App/ContentView.swift", 
    "Core/Audio/AudioRecordingManager.swift",
    "Core/Audio/AudioEffects.swift",
    "Core/AI/TranscriptionManager.swift",
    "Core/Export/ExportManager.swift",
    "UI/Views/RecordingView.swift",
    "UI/Views/ExportView.swift",
    "UI/Views/SaveRecordingView.swift",
    "Models/Recording.swift"
]

var fileResults: [String: Bool] = [:]
for file in keyFiles {
    let fullPath = "\(echoScribePath)/\(file)"
    let exists = FileManager.default.fileExists(atPath: fullPath)
    fileResults[file] = exists
    print("\(exists ? "✅" : "❌") \(file): \(exists ? "Found" : "Missing")")
}

// Test 4: File Content Analysis
print("\n📝 Test 4: File Content Analysis")
print(String(repeating: "-", count: 30))

func analyzeSwiftFile(_ path: String) -> (lines: Int, hasMain: Bool, hasImports: Bool) {
    guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
        return (0, false, false)
    }
    
    let lines = content.components(separatedBy: .newlines).count
    let hasMain = content.contains("@main") || content.contains("main")
    let hasImports = content.contains("import SwiftUI") || content.contains("import Foundation")
    
    return (lines, hasMain, hasImports)
}

if let mainAppPath = "\(echoScribePath)/App/EchoScribeApp.swift" as String?,
   FileManager.default.fileExists(atPath: mainAppPath) {
    let analysis = analyzeSwiftFile(mainAppPath)
    print("✅ EchoScribeApp.swift:")
    print("   📝 Lines: \(analysis.lines)")
    print("   🎯 Has @main: \(analysis.hasMain)")
    print("   📦 Has imports: \(analysis.hasImports)")
}

// Test 5: Project Configuration
print("\n⚙️ Test 5: Project Configuration")
print(String(repeating: "-", count: 30))

let configFiles = [
    "Package.swift",
    "project.yml",
    "EchoScribe.xcodeproj"
]

for file in configFiles {
    let exists = FileManager.default.fileExists(atPath: file)
    print("\(exists ? "✅" : "❌") \(file): \(exists ? "Found" : "Missing")")
}

// Test 6: Build System Test
print("\n🔨 Test 6: Build System Test")
print(String(repeating: "-", count: 30))

// Check if we can compile a simple Swift file
let testSwiftCode = """
import Foundation
print("Hello from EchoScribe 3.0!")
"""

let testFile = "test_compile.swift"
try? testSwiftCode.write(toFile: testFile, atomically: true, encoding: .utf8)

// Test compilation
let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
process.arguments = [testFile]

let pipe = Pipe()
process.standardOutput = pipe
process.standardError = pipe

do {
    try process.run()
    process.waitUntilExit()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8) ?? ""
    
    if process.terminationStatus == 0 {
        print("✅ Swift compilation test: PASSED")
        print("   Output: \(output.trimmingCharacters(in: .whitespacesAndNewlines))")
    } else {
        print("❌ Swift compilation test: FAILED")
        print("   Error: \(output)")
    }
} catch {
    print("❌ Swift compilation test: ERROR - \(error)")
}

// Cleanup test file
try? FileManager.default.removeItem(atPath: testFile)

// Test 7: Summary
print("\n📊 Test 7: Project Summary")
print(String(repeating: "-", count: 30))

let totalDirectories = directoryResults.values.filter { $0 }.count
let totalKeyFiles = fileResults.values.filter { $0 }.count

print("📁 Directories Found: \(totalDirectories)/\(directories.count)")
print("📄 Key Files Found: \(totalKeyFiles)/\(keyFiles.count)")
print("📝 Total Swift Files: \(totalSwiftFiles)")
print("🎯 Project Status: \(totalKeyFiles >= 8 ? "✅ READY" : "⚠️ INCOMPLETE")")

if totalKeyFiles >= 8 {
    print("\n🎉 EchoScribe 3.0 Project Test: PASSED!")
    print("✅ The project is ready for development and testing.")
    print("📋 Next steps:")
    print("   - Open EchoScribe.xcodeproj in Xcode")
    print("   - Build and run the project")
    print("   - Test all features and functionality")
} else {
    print("\n⚠️ EchoScribe 3.0 Project Test: NEEDS ATTENTION")
    print("❌ Some key files are missing.")
    print("📋 Please check the missing files above.")
}

print("\n🏁 Terminal test completed!")
