import Cocoa
import SwiftUI

// MARK: - MenuBarApp

@main
struct MenuBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @AppStorage("fixGrammar_shortcut") var fixGrammarShortcut: String = ShortcutManager.Shortcut(key: "3", modifier: .control).toJSON()
    
    var body: some Scene {
        MenuBarExtra("Menu Bar App", systemImage: "square.and.pencil") {
            Button("Fix Grammar") {
                Task {
                    await fixGrammar()
                }
            }
            .if(fixGrammarShortcut, map: { ShortcutManager.Shortcut.fromJSON($0) }) { (view, shortcut: ShortcutManager.Shortcut)  in
                view.keyboardShortcut(.init(from: shortcut))
            }
            Divider()
            SettingsLink(label: {
                Text("Preferences")
            })
            Button("Exit") {
                NSApplication.shared.terminate(self)
            }
            Divider()
            // show version info
            Text("Version: 0.1 alpha")
        }
        .menuBarExtraStyle(.menu)
        .defaultSize(width: 100, height: 100)
        
        Settings {
            SettingsView()
        }
    }
    
    private func fixGrammar() async {
        guard let selectedText = await TextControl.getSelectedTextFromScreen() else {
            return
        }
        
        do {
            let fixGrammarPrompt = UserDefaults.standard.string(forKey: "fixGrammerPrompt") ?? ""
            let result = try await TextProcessor.shared.requestCompletion(selectedText, system: fixGrammarPrompt)
            TextControl.replaceSelectedTextOnScreen(with: result)
        } catch {
            print("Error fixing grammar: \(error)")
        }
    }
}


// MARK: - AppDelegate

class AppDelegate: NSObject, NSApplicationDelegate {
    var settingsWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        TextControl.requestAccessibilityPermissions()
        NSApp.setActivationPolicy(.accessory) // Keep the app alive when closing the dock icon
    }
    
    func openSettings() {
        if settingsWindow == nil {
            let settingsView = SettingsView()
            let hostingController = NSHostingController(rootView: settingsView)
            settingsWindow = NSWindow(
                contentViewController: hostingController
            )
            settingsWindow?.title = "Rewrite Settings"
            settingsWindow?.center()
        }
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder func `if`<S, T, Content: View>(_ state: S, map: (S) -> T?, transform: (Self, T) -> Content) -> some View {
        if let state = map(state) {
            transform(self, state)
        } else {
            self
        }
    }
}
