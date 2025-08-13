#!/bin/bash

# Create Simple Xcode Project
echo "🎯 Creating Simple Xcode Project"

# Create project directory structure
mkdir -p EchoScribe.xcodeproj/project.xcworkspace

# Create a minimal but working project.pbxproj
cat > EchoScribe.xcodeproj/project.pbxproj << 'EOF'
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
		1A000001 /* EchoScribeApp.swift in Sources */ = {isa = PBXBuildFile; fileRef = 1A000000 /* EchoScribeApp.swift */; };
		1A000003 /* ContentView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 1A000002 /* ContentView.swift */; };
		1A000005 /* AudioRecordingManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 1A000004 /* AudioRecordingManager.swift */; };
		1A000007 /* TranscriptionManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 1A000006 /* TranscriptionManager.swift */; };
		1A000009 /* NotesManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 1A000008 /* NotesManager.swift */; };
		1A00000B /* PermissionManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 1A00000A /* PermissionManager.swift */; };
		1A00000D /* SettingsManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 1A00000C /* SettingsManager.swift */; };
		1A00000F /* RecordingView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 1A00000E /* RecordingView.swift */; };
		1A000011 /* NotesView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 1A000010 /* NotesView.swift */; };
		1A000013 /* FilesView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 1A000012 /* FilesView.swift */; };
		1A000015 /* SettingsView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 1A000014 /* SettingsView.swift */; };
		1A000017 /* OnboardingView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 1A000016 /* OnboardingView.swift */; };
		1A000019 /* SetupView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 1A000018 /* SetupView.swift */; };
		1A00001B /* AudioUtils.swift in Sources */ = {isa = PBXBuildFile; fileRef = 1A00001A /* AudioUtils.swift */; };
		1A00001D /* DesignSystem.swift in Sources */ = {isa = PBXBuildFile; fileRef = 1A00001C /* DesignSystem.swift */; };
		1A00001F /* ViewExtensions.swift in Sources */ = {isa = PBXBuildFile; fileRef = 1A00001E /* ViewExtensions.swift */; };
		1A000021 /* AudioLevelMeter.swift in Sources */ = {isa = PBXBuildFile; fileRef = 1A000020 /* AudioLevelMeter.swift */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		1A000000 /* EchoScribeApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = EchoScribeApp.swift; sourceTree = "<group>"; };
		1A000002 /* ContentView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ContentView.swift; sourceTree = "<group>"; };
		1A000004 /* AudioRecordingManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AudioRecordingManager.swift; sourceTree = "<group>"; };
		1A000006 /* TranscriptionManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = TranscriptionManager.swift; sourceTree = "<group>"; };
		1A000008 /* NotesManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = NotesManager.swift; sourceTree = "<group>"; };
		1A00000A /* PermissionManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = PermissionManager.swift; sourceTree = "<group>"; };
		1A00000C /* SettingsManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SettingsManager.swift; sourceTree = "<group>"; };
		1A00000E /* RecordingView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = RecordingView.swift; sourceTree = "<group>"; };
		1A000010 /* NotesView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = NotesView.swift; sourceTree = "<group>"; };
		1A000012 /* FilesView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = FilesView.swift; sourceTree = "<group>"; };
		1A000014 /* SettingsView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SettingsView.swift; sourceTree = "<group>"; };
		1A000016 /* OnboardingView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = OnboardingView.swift; sourceTree = "<group>"; };
		1A000018 /* SetupView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SetupView.swift; sourceTree = "<group>"; };
		1A00001A /* AudioUtils.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AudioUtils.swift; sourceTree = "<group>"; };
		1A00001C /* DesignSystem.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = DesignSystem.swift; sourceTree = "<group>"; };
		1A00001E /* ViewExtensions.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ViewExtensions.swift; sourceTree = "<group>"; };
		1A000020 /* AudioLevelMeter.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AudioLevelMeter.swift; sourceTree = "<group>"; };
		1A000022 /* EchoScribe.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = EchoScribe.app; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		1A000023 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		1A000024 /* EchoScribe */ = {
			isa = PBXGroup;
			children = (
				1A000000 /* EchoScribeApp.swift */,
				1A000002 /* ContentView.swift */,
				1A000004 /* AudioRecordingManager.swift */,
				1A000006 /* TranscriptionManager.swift */,
				1A000008 /* NotesManager.swift */,
				1A00000A /* PermissionManager.swift */,
				1A00000C /* SettingsManager.swift */,
				1A00000E /* RecordingView.swift */,
				1A000010 /* NotesView.swift */,
				1A000012 /* FilesView.swift */,
				1A000014 /* SettingsView.swift */,
				1A000016 /* OnboardingView.swift */,
				1A000018 /* SetupView.swift */,
				1A00001A /* AudioUtils.swift */,
				1A00001C /* DesignSystem.swift */,
				1A00001E /* ViewExtensions.swift */,
				1A000020 /* AudioLevelMeter.swift */,
			);
			path = EchoScribe;
			sourceTree = "<group>";
		};
		1A000025 /* Products */ = {
			isa = PBXGroup;
			children = (
				1A000022 /* EchoScribe.app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
		1A000026 /* EchoScribe-Fresh */ = {
			isa = PBXGroup;
			children = (
				1A000024 /* EchoScribe */,
				1A000025 /* Products */,
			);
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		1A000027 /* EchoScribe */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = 1A000028 /* Build configuration list for PBXNativeTarget "EchoScribe" */;
			buildPhases = (
				1A000029 /* Sources */,
				1A000023 /* Frameworks */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = EchoScribe;
			productName = EchoScribe;
			productReference = 1A000022 /* EchoScribe.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		1A00002A /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1500;
				LastUpgradeCheck = 1500;
				TargetAttributes = {
					1A000027 = {
						CreatedOnToolsVersion = 15.0;
					};
				};
			};
			buildConfigurationList = 1A00002B /* Build configuration list for PBXProject "EchoScribe" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = 1A000026 /* EchoScribe-Fresh */;
			productRefGroup = 1A000025 /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				1A000027 /* EchoScribe */,
			);
		};
/* End PBXProject section */

/* Begin PBXSourcesBuildPhase section */
		1A000029 /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				1A000001 /* EchoScribeApp.swift in Sources */,
				1A000003 /* ContentView.swift in Sources */,
				1A000005 /* AudioRecordingManager.swift in Sources */,
				1A000007 /* TranscriptionManager.swift in Sources */,
				1A000009 /* NotesManager.swift in Sources */,
				1A00000B /* PermissionManager.swift in Sources */,
				1A00000D /* SettingsManager.swift in Sources */,
				1A00000F /* RecordingView.swift in Sources */,
				1A000011 /* NotesView.swift in Sources */,
				1A000013 /* FilesView.swift in Sources */,
				1A000015 /* SettingsView.swift in Sources */,
				1A000017 /* OnboardingView.swift in Sources */,
				1A000019 /* SetupView.swift in Sources */,
				1A00001B /* AudioUtils.swift in Sources */,
				1A00001D /* DesignSystem.swift in Sources */,
				1A00001F /* ViewExtensions.swift in Sources */,
				1A000021 /* AudioLevelMeter.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		1A00002C /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MACOSX_DEPLOYMENT_TARGET = 13.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = macosx;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			};
			name = Debug;
		};
		1A00002D /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MACOSX_DEPLOYMENT_TARGET = 13.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = macosx;
				SWIFT_COMPILATION_MODE = wholemodule;
			};
			name = Release;
		};
		1A00002E /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				COMBINE_HIDPI_IMAGES = YES;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_ASSET_PATHS = "";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_NSMicrophoneUsageDescription = "EchoScribe needs microphone access to record audio for transcription.";
				INFOPLIST_KEY_NSSystemAdministrationUsageDescription = "EchoScribe needs system administration access to record system audio.";
				INFOPLIST_KEY_NSScreenCaptureUsageDescription = "EchoScribe needs screen capture access to record system audio.";
				INFOPLIST_KEY_NSDocumentsFolderUsageDescription = "EchoScribe needs access to your Documents folder to save recordings and notes.";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.echoscribe.app;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
			};
			name = Debug;
		};
		1A00002F /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				COMBINE_HIDPI_IMAGES = YES;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_ASSET_PATHS = "";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_NSMicrophoneUsageDescription = "EchoScribe needs microphone access to record audio for transcription.";
				INFOPLIST_KEY_NSSystemAdministrationUsageDescription = "EchoScribe needs system administration access to record system audio.";
				INFOPLIST_KEY_NSScreenCaptureUsageDescription = "EchoScribe needs screen capture access to record system audio.";
				INFOPLIST_KEY_NSDocumentsFolderUsageDescription = "EchoScribe needs access to your Documents folder to save recordings and notes.";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.echoscribe.app;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		1A000028 /* Build configuration list for PBXNativeTarget "EchoScribe" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				1A00002E /* Debug */,
				1A00002F /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		1A00002B /* Build configuration list for PBXProject "EchoScribe" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				1A00002C /* Debug */,
				1A00002D /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */
	};
	rootObject = 1A00002A /* Project object */;
}
EOF

# Create workspace
cat > EchoScribe.xcodeproj/project.xcworkspace/contents.xcworkspacedata << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "self:EchoScribe.xcodeproj">
   </FileRef>
</Workspace>
EOF

echo "✅ Project created successfully!"
echo "📱 To open: open EchoScribe.xcodeproj"
