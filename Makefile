# Requires GNU Make. Run the commands from the project root.
# Optional: make run-android DEVICE=<android-device-id>

.DEFAULT_GOAL := help

FLUTTER ?= flutter
DART ?= dart
DEVICE ?=
DART_DEFINES_FILE ?= dart_defines.local.json
DART_DEFINES := --dart-define-from-file=$(DART_DEFINES_FILE)
APK_SOURCE := build/app/outputs/flutter-apk/app-release.apk
APK_OUTPUT := build/app/outputs/flutter-apk/saldo-sh-android-release.apk

.PHONY: help doctor devices get clean format format-check analyze test coverage \
	test-one codegen icons run-android run-windows build-apk build-aab \
	build-windows build-android quality release

help: ## Show the available commands.
	@echo "saldo.sh - Flutter commands"
	@echo ""
	@echo "Setup and quality:"
	@echo "  make get              Fetch project dependencies"
	@echo "  make doctor           Check the local Flutter environment"
	@echo "  make devices          List available devices"
	@echo "  make format           Format Dart sources"
	@echo "  make format-check     Check formatting without changing files"
	@echo "  make analyze          Run static analysis"
	@echo "  make test             Run the complete test suite with local defines"
	@echo "  make coverage         Run tests and generate coverage/lcov.info"
	@echo "  make test-one TEST=... Run one test file or directory"
	@echo "  make codegen          Generate Drift/build_runner files"
	@echo ""
	@echo "Development:"
	@echo "  make run-android [DEVICE=<id>]  Run on a connected Android device"
	@echo "  make run-windows                   Run the Windows app"
	@echo "  make icons                         Regenerate launcher icons"
	@echo "  make clean                         Remove generated build files"
	@echo ""
	@echo "Release artifacts:"
	@echo "  make build-apk       Create saldo-sh-android-release.apk"
	@echo "  make build-aab       Create an Android App Bundle for Play Store"
	@echo "  make build-windows   Create the Windows release bundle"
	@echo "  make release         Run quality checks and create all artifacts"
	@echo "  Override defines: make build-apk DART_DEFINES_FILE=path/to/defines.json"

doctor: ## Check the Flutter SDK and platform toolchains.
	$(FLUTTER) doctor

devices: ## List physical devices and emulators.
	$(FLUTTER) devices

get: ## Fetch dependencies from pubspec.yaml.
	$(FLUTTER) pub get

clean: ## Remove generated build files and fetch dependencies again.
	$(FLUTTER) clean
	$(FLUTTER) pub get

format: ## Apply the standard Dart formatter.
	$(DART) format lib test tool

format-check: ## Check formatting without modifying files.
	$(DART) format --output=none --set-exit-if-changed lib test tool

analyze: ## Run the Flutter analyzer.
	$(FLUTTER) analyze

test: ## Run all unit and widget tests.
	$(FLUTTER) test $(DART_DEFINES)

coverage: ## Run tests and write coverage/lcov.info.
	$(FLUTTER) test --coverage $(DART_DEFINES)

test-one: ## Example: make test-one TEST=test/widget_test.dart
	$(if $(TEST),,$(error Set TEST, e.g. make test-one TEST=test/widget_test.dart))
	$(FLUTTER) test $(TEST) $(DART_DEFINES)

codegen: ## Regenerate files produced by build_runner (for example, Drift).
	$(FLUTTER) pub run build_runner build --delete-conflicting-outputs

icons: ## Regenerate launcher icons from assets/icon.
	$(FLUTTER) pub run flutter_launcher_icons

run-android: ## Run on Android; set DEVICE when more than one is connected.
	$(FLUTTER) run $(if $(DEVICE),-d $(DEVICE),) $(DART_DEFINES)

run-windows: ## Run the Windows desktop app.
	$(FLUTTER) run -d windows $(DART_DEFINES)

build-apk: ## Build build/app/outputs/flutter-apk/saldo-sh-android-release.apk.
	$(FLUTTER) build apk --release $(DART_DEFINES)
	mv -f $(APK_SOURCE) $(APK_OUTPUT)

build-aab: ## Build build/app/outputs/bundle/release/app-release.aab.
	$(FLUTTER) build appbundle --release $(DART_DEFINES)

build-windows: ## Build build/windows/x64/runner/Release/.
	$(FLUTTER) build windows --release $(DART_DEFINES)

build-android: build-apk build-aab ## Build both Android release artifacts.

quality: format-check analyze test ## Run all local quality checks.

release: quality build-android build-windows ## Validate and build Android/Windows release artifacts.
	@echo "Release artifacts generated under build/."
	@echo "Android publishing requires a production signing configuration."
