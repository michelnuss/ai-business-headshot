#!/usr/bin/env python3
"""Generate the app icon and a complete Xcode project.pbxproj + shared scheme."""

from __future__ import annotations

import uuid
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

ROOT = Path("/workspace")
APP = ROOT / "Headshot"
PROJECT = ROOT / "Headshot.xcodeproj"


def xid() -> str:
    return uuid.uuid4().hex[:24].upper()


def draw_icon(path: Path) -> None:
    size = 1024
    img = Image.new("RGB", (size, size), "#16181C")
    overlay = Image.new("RGB", (size, size), "#16181C")
    draw = ImageDraw.Draw(overlay)

    cx, cy = size / 2, size / 2 - 30
    for radius in range(520, 0, -8):
        t = 1 - radius / 520
        shade = int(22 + 48 * (1 - t) ** 2)
        color = (shade + 8, shade + 10, shade + 16)
        draw.ellipse((cx - radius, cy - radius + 40, cx + radius, cy + radius + 40), fill=color)

    img = Image.blend(img, overlay, 0.9)
    draw = ImageDraw.Draw(img)

    ring_r = 310
    draw.ellipse(
        (cx - ring_r, cy - ring_r + 20, cx + ring_r, cy + ring_r + 20),
        outline=(214, 186, 142, 255),
        width=10,
    )

    # Shoulders
    shoulder = (cx, cy + 210)
    draw.ellipse(
        (cx - 210, shoulder[1] - 40, cx + 210, shoulder[1] + 260),
        fill=(214, 211, 205),
    )
    # Head
    draw.ellipse((cx - 118, cy - 150, cx + 118, cy + 100), fill=(232, 228, 221))

    img = img.filter(ImageFilter.GaussianBlur(radius=0.4))
    # Re-draw crisp ring after slight blur of silhouette
    draw = ImageDraw.Draw(img)
    draw.ellipse(
        (cx - ring_r, cy - ring_r + 20, cx + ring_r, cy + ring_r + 20),
        outline=(214, 186, 142),
        width=8,
    )
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path, "PNG")


SWIFT_FILES = [
    ("HeadshotApp.swift", "HeadshotApp.swift"),
    ("App/AppConfig.swift", "AppConfig.swift"),
    ("App/StudioPalette.swift", "StudioPalette.swift"),
    ("Studio/StudioPhase.swift", "StudioPhase.swift"),
    ("Studio/StudioView.swift", "StudioView.swift"),
    ("Studio/StudioViewModel.swift", "StudioViewModel.swift"),
    ("Studio/BeforeAfterSlider.swift", "BeforeAfterSlider.swift"),
    ("Capture/CaptureViews.swift", "CaptureViews.swift"),
    ("Services/HeadshotService.swift", "HeadshotService.swift"),
    ("Services/PortraitStudio.swift", "PortraitStudio.swift"),
    ("Services/ImageSupport.swift", "ImageSupport.swift"),
]


PROJECT_DEBUG_SETTINGS = """
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
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
				SWIFT_STRICT_CONCURRENCY = targeted;
""".strip("\n")

PROJECT_RELEASE_SETTINGS = """
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
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_OPTIMIZATION_LEVEL = "-O";
				SWIFT_STRICT_CONCURRENCY = targeted;
				VALIDATE_PRODUCT = YES;
""".strip("\n")

TARGET_SETTINGS = """
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_ASSET_PATHS = "\\"Headshot/Preview Content\\"";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_FILE = Headshot/Info.plist;
				INFOPLIST_KEY_CFBundleDisplayName = Headshot;
				INFOPLIST_KEY_LSApplicationCategoryType = "public.app-category.photography";
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations = UIInterfaceOrientationPortrait;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.example.headshot;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SUPPORTS_MACCATALYST = NO;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = 1;
""".strip("\n")


def write_pbxproj() -> str:
    ids = {
        "project": xid(),
        "target": xid(),
        "product": xid(),
        "sources": xid(),
        "frameworks": xid(),
        "resources": xid(),
        "project_cfgs": xid(),
        "target_cfgs": xid(),
        "project_debug": xid(),
        "project_release": xid(),
        "target_debug": xid(),
        "target_release": xid(),
        "main_group": xid(),
        "products_group": xid(),
        "app_group": xid(),
        "app_sub": xid(),
        "studio_sub": xid(),
        "capture_sub": xid(),
        "services_sub": xid(),
        "preview_group": xid(),
        "assets": xid(),
        "assets_build": xid(),
        "privacy": xid(),
        "privacy_build": xid(),
        "preview_assets": xid(),
        "info": xid(),
    }

    file_entries = []
    for rel, name in SWIFT_FILES:
        file_entries.append(
            {
                "rel": rel,
                "name": name,
                "ref": xid(),
                "build": xid(),
            }
        )

    def children(entries):
        return "".join(f"\t\t\t\t{e['ref']} /* {e['name']} */,\n" for e in entries)

    root_swift = [e for e in file_entries if e["rel"] == "HeadshotApp.swift"]
    app_swift = [e for e in file_entries if e["rel"].startswith("App/")]
    studio_swift = [e for e in file_entries if e["rel"].startswith("Studio/")]
    capture_swift = [e for e in file_entries if e["rel"].startswith("Capture/")]
    services_swift = [e for e in file_entries if e["rel"].startswith("Services/")]

    build_files = []
    for e in file_entries:
        build_files.append(
            f"\t\t{e['build']} /* {e['name']} in Sources */ = {{isa = PBXBuildFile; fileRef = {e['ref']} /* {e['name']} */; }};"
        )
    build_files.append(
        f"\t\t{ids['assets_build']} /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {ids['assets']} /* Assets.xcassets */; }};"
    )
    build_files.append(
        f"\t\t{ids['privacy_build']} /* PrivacyInfo.xcprivacy in Resources */ = {{isa = PBXBuildFile; fileRef = {ids['privacy']} /* PrivacyInfo.xcprivacy */; }};"
    )

    file_refs = []
    for e in file_entries:
        file_refs.append(
            f"\t\t{e['ref']} /* {e['name']} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {e['name']}; sourceTree = \"<group>\"; }};"
        )
    file_refs.append(
        f"\t\t{ids['product']} /* Headshot.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = Headshot.app; sourceTree = BUILT_PRODUCTS_DIR; }};"
    )
    file_refs.append(
        f"\t\t{ids['assets']} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = \"<group>\"; }};"
    )
    file_refs.append(
        f"\t\t{ids['privacy']} /* PrivacyInfo.xcprivacy */ = {{isa = PBXFileReference; lastKnownFileType = text.xml; path = PrivacyInfo.xcprivacy; sourceTree = \"<group>\"; }};"
    )
    file_refs.append(
        f"\t\t{ids['info']} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = \"<group>\"; }};"
    )
    file_refs.append(
        f"\t\t{ids['preview_assets']} /* Preview Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = \"Preview Assets.xcassets\"; sourceTree = \"<group>\"; }};"
    )

    sources_list = "".join(
        f"\t\t\t\t{e['build']} /* {e['name']} in Sources */,\n" for e in file_entries
    )

    pbx = f"""// !$*UTF8*$!
{{
	archiveVersion = 1;
	classes = {{
	}};
	objectVersion = 56;
	objects = {{

/* Begin PBXBuildFile section */
{chr(10).join(build_files)}
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
{chr(10).join(file_refs)}
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		{ids['frameworks']} /* Frameworks */ = {{
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		{ids['main_group']} = {{
			isa = PBXGroup;
			children = (
				{ids['app_group']} /* Headshot */,
				{ids['products_group']} /* Products */,
			);
			sourceTree = "<group>";
		}};
		{ids['products_group']} /* Products */ = {{
			isa = PBXGroup;
			children = (
				{ids['product']} /* Headshot.app */,
			);
			name = Products;
			sourceTree = "<group>";
		}};
		{ids['app_group']} /* Headshot */ = {{
			isa = PBXGroup;
			children = (
{children(root_swift)}				{ids['app_sub']} /* App */,
				{ids['studio_sub']} /* Studio */,
				{ids['capture_sub']} /* Capture */,
				{ids['services_sub']} /* Services */,
				{ids['assets']} /* Assets.xcassets */,
				{ids['info']} /* Info.plist */,
				{ids['privacy']} /* PrivacyInfo.xcprivacy */,
				{ids['preview_group']} /* Preview Content */,
			);
			path = Headshot;
			sourceTree = "<group>";
		}};
		{ids['app_sub']} /* App */ = {{
			isa = PBXGroup;
			children = (
{children(app_swift)}			);
			path = App;
			sourceTree = "<group>";
		}};
		{ids['studio_sub']} /* Studio */ = {{
			isa = PBXGroup;
			children = (
{children(studio_swift)}			);
			path = Studio;
			sourceTree = "<group>";
		}};
		{ids['capture_sub']} /* Capture */ = {{
			isa = PBXGroup;
			children = (
{children(capture_swift)}			);
			path = Capture;
			sourceTree = "<group>";
		}};
		{ids['services_sub']} /* Services */ = {{
			isa = PBXGroup;
			children = (
{children(services_swift)}			);
			path = Services;
			sourceTree = "<group>";
		}};
		{ids['preview_group']} /* Preview Content */ = {{
			isa = PBXGroup;
			children = (
				{ids['preview_assets']} /* Preview Assets.xcassets */,
			);
			path = "Preview Content";
			sourceTree = "<group>";
		}};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		{ids['target']} /* Headshot */ = {{
			isa = PBXNativeTarget;
			buildConfigurationList = {ids['target_cfgs']} /* Build configuration list for PBXNativeTarget "Headshot" */;
			buildPhases = (
				{ids['sources']} /* Sources */,
				{ids['frameworks']} /* Frameworks */,
				{ids['resources']} /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = Headshot;
			productName = Headshot;
			productReference = {ids['product']} /* Headshot.app */;
			productType = "com.apple.product-type.application";
		}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		{ids['project']} /* Project object */ = {{
			isa = PBXProject;
			attributes = {{
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1540;
				LastUpgradeCheck = 1540;
				TargetAttributes = {{
					{ids['target']} = {{
						CreatedOnToolsVersion = 15.4;
					}};
				}};
			}};
			buildConfigurationList = {ids['project_cfgs']} /* Build configuration list for PBXProject "Headshot" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = {ids['main_group']};
			productRefGroup = {ids['products_group']} /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				{ids['target']} /* Headshot */,
			);
		}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		{ids['resources']} /* Resources */ = {{
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				{ids['privacy_build']} /* PrivacyInfo.xcprivacy in Resources */,
				{ids['assets_build']} /* Assets.xcassets in Resources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		{ids['sources']} /* Sources */ = {{
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
{sources_list}			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		{ids['project_debug']} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
{PROJECT_DEBUG_SETTINGS}
			}};
			name = Debug;
		}};
		{ids['project_release']} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
{PROJECT_RELEASE_SETTINGS}
			}};
			name = Release;
		}};
		{ids['target_debug']} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
{TARGET_SETTINGS}
			}};
			name = Debug;
		}};
		{ids['target_release']} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
{TARGET_SETTINGS}
			}};
			name = Release;
		}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		{ids['project_cfgs']} /* Build configuration list for PBXProject "Headshot" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{ids['project_debug']} /* Debug */,
				{ids['project_release']} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
		{ids['target_cfgs']} /* Build configuration list for PBXNativeTarget "Headshot" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{ids['target_debug']} /* Debug */,
				{ids['target_release']} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
/* End XCConfigurationList section */
	}};
	rootObject = {ids['project']} /* Project object */;
}}
"""
    # Fix accidental typo if any
    pbx = pbx.replace(" mar\t\t\ttargets", "\t\t\ttargets")
    pbx = pbx.replace(" mar\t\t\ttargets", "\t\t\ttargets")
    PROJECT.mkdir(parents=True, exist_ok=True)
    (PROJECT / "project.pbxproj").write_text(pbx)
    return ids["target"]


def write_workspace() -> None:
    workspace = PROJECT / "project.xcworkspace"
    workspace.mkdir(parents=True, exist_ok=True)
    (workspace / "contents.xcworkspacedata").write_text(
        """<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "self:">
   </FileRef>
</Workspace>
"""
    )


def write_scheme(target_id: str) -> None:
    scheme_dir = PROJECT / "xcshareddata" / "xcschemes"
    scheme_dir.mkdir(parents=True, exist_ok=True)
    (scheme_dir / "Headshot.xcscheme").write_text(
        f"""<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1540"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{target_id}"
               BuildableName = "Headshot.app"
               BlueprintName = "Headshot"
               ReferencedContainer = "container:Headshot.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES"
      shouldAutocreateTestPlan = "YES">
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{target_id}"
            BuildableName = "Headshot.app"
            BlueprintName = "Headshot"
            ReferencedContainer = "container:Headshot.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{target_id}"
            BuildableName = "Headshot.app"
            BlueprintName = "Headshot"
            ReferencedContainer = "container:Headshot.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
"""
    )


def main() -> None:
    draw_icon(APP / "Assets.xcassets" / "AppIcon.appiconset" / "AppIcon.png")
    target_id = write_pbxproj()
    write_workspace()
    write_scheme(target_id)
    print("Wrote project, scheme, and app icon")
    print("target_id", target_id)


if __name__ == "__main__":
    main()
