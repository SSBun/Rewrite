import Cocoa
import SwiftUI

// MARK: - MenuBarApp

@main
struct MenuBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        MenuBarExtra("Menu Bar App", systemImage: "square.and.pencil") {
            Button("Item 1") {
                // Handle Item 1 action
            }
            Button("Item 2") {
                // Handle Item 2 action
            }
            Button("Item 3") {
                // Handle Item 3 action
            }
            Divider()
            Button("Exit") {
                NSApplication.shared.terminate(self)
            }
            SettingsLink(label: {
                Text("Preferences")
            })
        }
        .menuBarExtraStyle(.menu)
        
        Settings {
            SettingsView()
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

