import AppKit

class StatusBarController: NSObject, NSMenuDelegate {
    private let statusItem: NSStatusItem
    private let menu: NSMenu

    override init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        menu = NSMenu()

        super.init()

        if let button = statusItem.button {
            if let image = NSImage(systemSymbolName: "list.clipboard", accessibilityDescription: "Claude Plans") {
                image.isTemplate = true
                button.image = image
            } else {
                button.title = "CP"
            }
        }

        menu.delegate = self
        statusItem.menu = menu
    }

    // MARK: - NSMenuDelegate

    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()

        let plans = PlanScanner.scan(max: ConfigManager.shared.config.maxPlans)

        if plans.isEmpty {
            let emptyItem = NSMenuItem(title: "No plans found", action: nil, keyEquivalent: "")
            emptyItem.isEnabled = false
            menu.addItem(emptyItem)
        } else {
            for plan in plans {
                let item = NSMenuItem()
                item.attributedTitle = makeAttributedTitle(for: plan)
                item.representedObject = plan.filePath
                item.target = self
                item.action = #selector(openPlan(_:))
                menu.addItem(item)
            }
        }

        menu.addItem(.separator())

        let configItem = NSMenuItem(title: "Configure...", action: #selector(openConfig), keyEquivalent: ",")
        configItem.target = self
        menu.addItem(configItem)

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
    }

    // MARK: - Menu item formatting

    private func makeAttributedTitle(for plan: PlanItem) -> NSAttributedString {
        let result = NSMutableAttributedString()

        // Line 1: filename (bold)
        let nameAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 13, weight: .semibold),
            .foregroundColor: NSColor.labelColor
        ]
        result.append(NSAttributedString(string: plan.fileName + "\n", attributes: nameAttrs))

        // Line 2: title + tab-aligned time
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.tabStops = [NSTextTab(textAlignment: .right, location: 340)]
        paraStyle.lineBreakMode = .byTruncatingMiddle

        let subtitleAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 11.5),
            .foregroundColor: NSColor.secondaryLabelColor,
            .paragraphStyle: paraStyle
        ]

        let timeString = DateFormatting.format(plan.modificationDate)
        let line2 = plan.title + "\t" + timeString
        result.append(NSAttributedString(string: line2, attributes: subtitleAttrs))

        return result
    }

    // MARK: - Actions

    @objc private func openPlan(_ sender: NSMenuItem) {
        guard let path = sender.representedObject as? String else { return }
        EditorLauncher.open(filePath: path)
    }

    private var configWindowController: ConfigWindowController?

    @objc private func openConfig() {
        if configWindowController == nil {
            configWindowController = ConfigWindowController()
        }
        configWindowController?.showWindow()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
