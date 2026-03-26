APP_NAME := Claude Plans
EXECUTABLE := ClaudePlansMenu
VERSION := 1.0.0

BUILD_DIR := .build
APP_BUNDLE := $(BUILD_DIR)/$(APP_NAME).app
DMG_NAME := ClaudePlansMenu-$(VERSION).dmg

.PHONY: dev build-arm64 build-x86_64 universal app dmg release clean

# Development: build and run
dev:
	swift build
	swift run

# Build for each architecture
build-arm64:
	swift build -c release --triple arm64-apple-macosx

build-x86_64:
	swift build -c release --triple x86_64-apple-macosx

# Create universal binary
universal: build-arm64 build-x86_64
	mkdir -p $(BUILD_DIR)/universal
	lipo -create \
		$(BUILD_DIR)/arm64-apple-macosx/release/$(EXECUTABLE) \
		$(BUILD_DIR)/x86_64-apple-macosx/release/$(EXECUTABLE) \
		-output $(BUILD_DIR)/universal/$(EXECUTABLE)

# Create .app bundle
app: universal
	rm -rf "$(APP_BUNDLE)"
	mkdir -p "$(APP_BUNDLE)/Contents/MacOS"
	mkdir -p "$(APP_BUNDLE)/Contents/Resources"
	cp $(BUILD_DIR)/universal/$(EXECUTABLE) "$(APP_BUNDLE)/Contents/MacOS/$(EXECUTABLE)"
	cp Resources/Info.plist "$(APP_BUNDLE)/Contents/"
	@echo "Built $(APP_BUNDLE)"

# Create DMG
dmg: app
	rm -f "$(BUILD_DIR)/$(DMG_NAME)"
	rm -rf $(BUILD_DIR)/dmg-staging
	mkdir -p $(BUILD_DIR)/dmg-staging
	cp -R "$(APP_BUNDLE)" $(BUILD_DIR)/dmg-staging/
	ln -sf /Applications $(BUILD_DIR)/dmg-staging/Applications
	hdiutil create -volname "$(APP_NAME)" \
		-srcfolder $(BUILD_DIR)/dmg-staging \
		-ov -format UDZO \
		"$(BUILD_DIR)/$(DMG_NAME)"
	rm -rf $(BUILD_DIR)/dmg-staging
	@echo "Created $(BUILD_DIR)/$(DMG_NAME)"

# Full release pipeline
release: dmg

clean:
	rm -rf "$(APP_BUNDLE)" $(BUILD_DIR)/universal $(BUILD_DIR)/dmg-staging $(BUILD_DIR)/$(DMG_NAME)
	swift package clean
