import AppKit

class ConfigWindowController: NSObject {
    private var window: NSWindow?
    private var plansField: NSTextField!
    private var editorPopup: NSPopUpButton!
    private var customField: NSTextField!

    private static let editors: [(name: String, command: String)] = [
        ("VS Code", "code"),
        ("Zed", "zed"),
        ("Sublime Text", "subl"),
        ("TextEdit", "open -a TextEdit"),
    ]

    func showWindow() {
        if let window = window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 200),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Claude Plans Settings"
        window.center()
        window.isReleasedWhenClosed = false

        let contentView = NSView(frame: window.contentView!.bounds)
        contentView.autoresizingMask = [.width, .height]

        // Plans to show
        let plansLabel = NSTextField(labelWithString: "Plans to show:")
        plansLabel.frame = NSRect(x: 20, y: 140, width: 120, height: 22)

        plansField = NSTextField(string: "")
        plansField.frame = NSRect(x: 220, y: 140, width: 140, height: 22)
        let formatter = NumberFormatter()
        formatter.minimum = 1
        formatter.maximum = 50
        formatter.allowsFloats = false
        plansField.formatter = formatter

        // Editor
        let editorLabel = NSTextField(labelWithString: "Editor:")
        editorLabel.frame = NSRect(x: 20, y: 105, width: 120, height: 22)

        editorPopup = NSPopUpButton(frame: NSRect(x: 220, y: 103, width: 140, height: 25), pullsDown: false)
        for editor in Self.editors {
            editorPopup.addItem(withTitle: editor.name)
        }
        editorPopup.addItem(withTitle: "Custom...")
        editorPopup.target = self
        editorPopup.action = #selector(editorSelectionChanged)

        // Custom command field
        let customLabel = NSTextField(labelWithString: "Command:")
        customLabel.frame = NSRect(x: 20, y: 70, width: 120, height: 22)

        customField = NSTextField(string: "")
        customField.frame = NSRect(x: 220, y: 70, width: 140, height: 22)
        customField.placeholderString = "/usr/local/bin/myeditor"

        contentView.addSubview(plansLabel)
        contentView.addSubview(plansField)
        contentView.addSubview(editorLabel)
        contentView.addSubview(editorPopup)
        contentView.addSubview(customLabel)
        contentView.addSubview(customField)

        // Buttons
        let cancelButton = NSButton(title: "Cancel", target: self, action: #selector(cancel))
        cancelButton.frame = NSRect(x: 210, y: 15, width: 80, height: 32)
        cancelButton.bezelStyle = .rounded

        let saveButton = NSButton(title: "Save", target: self, action: #selector(save))
        saveButton.frame = NSRect(x: 295, y: 15, width: 70, height: 32)
        saveButton.bezelStyle = .rounded
        saveButton.keyEquivalent = "\r"

        contentView.addSubview(cancelButton)
        contentView.addSubview(saveButton)

        window.contentView = contentView
        self.window = window

        loadCurrentConfig()

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func loadCurrentConfig() {
        let config = ConfigManager.shared.config
        plansField.integerValue = config.maxPlans

        // Find matching editor or set to Custom
        if let idx = Self.editors.firstIndex(where: { $0.command == config.editor }) {
            editorPopup.selectItem(at: idx)
            customField.isHidden = true
        } else {
            editorPopup.selectItem(withTitle: "Custom...")
            customField.stringValue = config.editor
            customField.isHidden = false
        }
    }

    @objc private func editorSelectionChanged() {
        let isCustom = editorPopup.titleOfSelectedItem == "Custom..."
        customField.isHidden = !isCustom
        // Also show/hide the custom label
        if let contentView = window?.contentView {
            for subview in contentView.subviews {
                if let tf = subview as? NSTextField, tf.stringValue == "Command:" {
                    tf.isHidden = !isCustom
                }
            }
        }
    }

    @objc private func cancel() {
        window?.close()
    }

    @objc private func save() {
        let maxPlans = max(1, plansField.integerValue)

        let editor: String
        if editorPopup.titleOfSelectedItem == "Custom..." {
            editor = customField.stringValue.trimmingCharacters(in: .whitespaces)
            if editor.isEmpty { return } // don't save empty custom command
        } else if let idx = editorPopup.indexOfSelectedItem as Int?,
                  idx < Self.editors.count {
            editor = Self.editors[idx].command
        } else {
            editor = "code"
        }

        let newConfig = AppConfig(maxPlans: maxPlans, editor: editor)
        ConfigManager.shared.save(newConfig)
        window?.close()
    }
}
