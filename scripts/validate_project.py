#!/usr/bin/env python3
"""Validate the Headshot Xcode project as far as this Linux environment allows."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path("/workspace")
APP = ROOT / "Headshot"
PBX = ROOT / "Headshot.xcodeproj" / "project.pbxproj"
SCHEME = ROOT / "Headshot.xcodeproj" / "xcshareddata" / "xcschemes" / "Headshot.xcscheme"
INFO = APP / "Info.plist"
CONFIG = APP / "App" / "AppConfig.swift"
SERVICE = APP / "Services" / "HeadshotService.swift"

failures: list[str] = []


def fail(message: str) -> None:
    failures.append(message)


def read(path: Path) -> str:
    if not path.exists():
        fail(f"Missing file: {path.relative_to(ROOT)}")
        return ""
    return path.read_text()


def swift_files() -> list[Path]:
    return sorted(APP.rglob("*.swift"))


def check_project_files() -> None:
    pbx = read(PBX)
    if not pbx.startswith("// !$*UTF8*$!"):
        fail("project.pbxproj is missing the Xcode header")
    if "rootObject" not in pbx:
        fail("project.pbxproj is missing rootObject")
    if "PRODUCT_BUNDLE_IDENTIFIER = com.yourcompany.headshot" not in pbx:
        fail("Bundle identifier placeholder is not set")
    if "IPHONEOS_DEPLOYMENT_TARGET = 17.0" not in pbx:
        fail("Deployment target should be iOS 17")
    if "INFOPLIST_FILE = Headshot/Info.plist" not in pbx:
        fail("Info.plist is not wired into build settings")
    if "ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon" not in pbx:
        fail("App icon catalog is not set")

    on_disk = {path.name for path in swift_files()}
    listed = set(re.findall(r"path = ([A-Za-z0-9]+(?:\.swift));", pbx))
    missing_from_pbx = on_disk - listed
    extra_in_pbx = listed - on_disk
    if missing_from_pbx:
        fail(f"Swift files not in pbxproj: {sorted(missing_from_pbx)}")
    if extra_in_pbx:
        fail(f"pbxproj lists Swift files that are not on disk: {sorted(extra_in_pbx)}")

    for rel in [
        "HeadshotApp.swift",
        "App/AppConfig.swift",
        "Studio/StudioView.swift",
        "Studio/StudioViewModel.swift",
        "Services/HeadshotService.swift",
        "Services/PortraitStudio.swift",
        "Info.plist",
        "Assets.xcassets/AppIcon.appiconset/AppIcon.png",
        "Assets.xcassets/AccentColor.colorset/Contents.json",
    ]:
        if not (APP / rel).exists():
            fail(f"Expected project file missing: Headshot/{rel}")

    if not SCHEME.exists():
        fail("Shared scheme Headshot.xcscheme is missing")
    else:
        scheme = SCHEME.read_text()
        target_ids = re.findall(r"([A-F0-9]{24}) /\* Headshot \*/ = \{\n\t\t\tisa = PBXNativeTarget", pbx)
        if target_ids and target_ids[0] not in scheme:
            fail("xcscheme BlueprintIdentifier does not match the native target id")


def check_braces() -> None:
    for path in swift_files():
        text = path.read_text()
        # Strip strings roughly so braces in copy don't throw the count off.
        stripped = re.sub(r'"""[\s\S]*?"""', '""', text)
        stripped = re.sub(r'"(?:\\.|[^"\\])*"', '""', stripped)
        if stripped.count("{") != stripped.count("}"):
            fail(f"Unbalanced braces in {path.relative_to(ROOT)}")
        if stripped.count("(") != stripped.count(")"):
            fail(f"Unbalanced parentheses in {path.relative_to(ROOT)}")


def check_secrets_and_config() -> None:
    config = read(CONFIG)
    service = read(SERVICE)
    info = read(INFO)
    all_swift = "\n".join(path.read_text() for path in swift_files())

    key_match = re.search(r'static let openAIAPIKey = "(.*)"', config)
    if not key_match:
        fail("AppConfig.swift is missing openAIAPIKey")
    elif key_match.group(1).strip():
        fail("openAIAPIKey must stay an empty placeholder")

    if re.search(r"sk-[A-Za-z0-9_-]{10,}", all_swift):
        fail("A lookalike API key is hardcoded in Swift sources")

    prompt = config.lower()
    for phrase in [
        "facial structure",
        "do not change facial geometry",
        "same person",
        "identity",
    ]:
        if phrase not in prompt:
            fail(f"Identity-preserving prompt is missing: {phrase!r}")

    if 'field("input_fidelity", "high")' not in service:
        fail("OpenAI client must send input_fidelity=high")
    if 'static let imageQuality = "medium"' not in config:
        fail("Cloud quality should default to medium for emerging-market cost")
    if "uploadMaxDimension" not in config:
        fail("AppConfig must cap upload size for slow networks")
    if "MockStudioService" not in service or "usesCloudAI" not in service:
        fail("Factory must switch to MockStudioService when no key is present")
    if 'static var usesCloudAI: Bool {\n        !forceMockStudio && isAPIKeyPresent\n    }' not in config:
        fail("usesCloudAI must require a present key and not be forced on")

    if "ITSAppUsesNonExemptEncryption" not in info:
        fail("Info.plist must declare HTTPS-only export compliance")
    if "UILaunchScreen" not in info:
        fail("Info.plist must declare a launch screen")
    for key in [
        "NSCameraUsageDescription",
        "NSPhotoLibraryAddUsageDescription",
        "NSPhotoLibraryUsageDescription",
    ]:
        if key not in info:
            fail(f"Info.plist is missing {key}")

    for rel in ["docs/APP_STORE.md", "docs/COSTS_AND_PRICING.md", "Headshot/Localizable.xcstrings", "Headshot/App/L10n.swift"]:
        if not (ROOT / rel).exists():
            fail(f"Missing {rel}")


def check_flow_surface() -> None:
    studio = read(APP / "Studio" / "StudioView.swift")
    for token in ["L10n.create", "L10n.camera", "L10n.library", "BeforeAfterSlider", "L10n.save", "L10n.share", "SettingsView"]:
        if token not in studio:
            fail(f"StudioView is missing UI for {token!r}")
    model = read(APP / "Studio" / "StudioViewModel.swift")
    if "HeadshotServiceFactory.make()" not in model:
        fail("View model does not call the headshot service factory")
    if "MockStudioService" not in read(SERVICE):
        fail("Mock studio service is missing")


def main() -> int:
    check_project_files()
    check_braces()
    check_secrets_and_config()
    check_flow_surface()
    if failures:
        print("Project validation failed:")
        for item in failures:
            print(f"  - {item}")
        return 1
    print(f"OK: {len(swift_files())} Swift files, Xcode project, mock path, empty API key, identity prompt.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
