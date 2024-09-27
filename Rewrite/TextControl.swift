//
//  TextControl.swift
//  Rewrite
//
//  Created by caishilin on 2024/9/26.
//

import Foundation
import Cocoa

class TextControl {
    
    private static func getSelectedTextByPasteBoard() async throws -> String? {
        KeySimulator.press(key: "c", with: [.command])
        // Wait a moment for the clipboard to update
        let result = await Task {
            try? await Task.sleep(nanoseconds: 100_000_000)
            if let copiedText = NSPasteboard.general.string(forType: .string) {
                return copiedText
            } else {
                return ""
            }
        }.result
        
        return try result.get()
    }
    
    private static func replaceSelectedTextByPasteBoard(with text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        KeySimulator.press(key: "v", with: [.command])
    }
    
    static func getSelectedTextFromScreen() async -> String? {
//        let runningApps = NSWorkspace.shared.runningApplications
        var focusedElement: AnyObject?
        var result: AXError = .failure
//        if let chromeApp = runningApps.first(where: { $0.bundleIdentifier == "com.google.Chrome" }) {
//            let pid = chromeApp.processIdentifier
//            let appElement = AXUIElementCreateApplication(pid)
//            
//            result = AXUIElementCopyAttributeValue(appElement, kAXFocusedUIElementAttribute as CFString, &focusedElement)
//            if result != .success {
//                focusedElement = nil
//            }
//        }
       
        if result == .failure {
            // Use accessibility APIs to get the selected text
            let systemWideElement = AXUIElementCreateSystemWide()
            result = AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedUIElementAttribute as CFString, &focusedElement)
        }
        
        if result != .success {
            print("Error getting focused element: \(result.rawValue), using pasteboard method")
//            return nil
            return try? await getSelectedTextByPasteBoard()
        }
        
        guard let element = focusedElement else {
            print("No focused element found.")
            return nil
        }
        
        var selectedText: AnyObject?
        let textResult = AXUIElementCopyAttributeValue(element as! AXUIElement, kAXSelectedTextAttribute as CFString, &selectedText)
        
        if textResult != .success {
            print("Error getting selected text: \(textResult.rawValue)")
            return nil
        }
        
        return selectedText as? String
    }

    static func replaceSelectedTextOnScreen(with text: String) {
//        let runningApps = NSWorkspace.shared.runningApplications
        var focusedElement: AnyObject?
        var result: AXError = .failure
//        if let chromeApp = runningApps.first(where: { $0.bundleIdentifier == "com.google.Chrome" }) {
//            let pid = chromeApp.processIdentifier
//            let appElement = AXUIElementCreateApplication(pid)
//            
//            result = AXUIElementCopyAttributeValue(appElement, kAXFocusedUIElementAttribute as CFString, &focusedElement)
//            if result != .success {
//                focusedElement = nil
//            }
//        }
       
        if result == .failure {
            // Use accessibility APIs to get the selected text
            let systemWideElement = AXUIElementCreateSystemWide()
            result = AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedUIElementAttribute as CFString, &focusedElement)
        }
        
        if result != .success {
            replaceSelectedTextByPasteBoard(with: text)
            return
        }
        
        guard let element = focusedElement else {
            print("No focused element found.")
            return
        }
        
        let textResult = AXUIElementSetAttributeValue(element as! AXUIElement, kAXSelectedTextAttribute as CFString, text as CFTypeRef)
        
        if textResult != .success {
            print("Error setting selected text: \(textResult.rawValue)")
        }
    }

    static func requestAccessibilityPermissions() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        
        if !accessEnabled {
            let alert = NSAlert()
            alert.messageText = "Accessibility Permissions Required"
            alert.informativeText = "Please enable accessibility permissions for this app in System Preferences."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Open System Preferences")
            alert.addButton(withTitle: "Cancel")
            
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                    NSWorkspace.shared.open(url)
                }
            }
        }
    }
}
