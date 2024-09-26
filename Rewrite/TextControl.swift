//
//  TextControl.swift
//  Rewrite
//
//  Created by caishilin on 2024/9/26.
//

import Foundation
import Cocoa

class TextControl {
    static func getSelectedTextFromScreen() -> String? {
        // Use accessibility APIs to get the selected text
        let systemWideElement = AXUIElementCreateSystemWide()
        var focusedElement: AnyObject?
        let result = AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedUIElementAttribute as CFString, &focusedElement)
        
        if result != .success {
            print("Error getting focused element: \(result.rawValue)")
            return nil
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
        // Use accessibility APIs to replace the selected text
        let systemWideElement = AXUIElementCreateSystemWide()
        var focusedElement: AnyObject?
        let result = AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedUIElementAttribute as CFString, &focusedElement)
        
        if result != .success {
            print("Error getting focused element: \(result.rawValue)")
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
