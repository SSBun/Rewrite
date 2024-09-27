//
//  ShortcutManager.swift
//  Rewrite
//
//  Created by caishilin on 2024/9/27.
//

import SwiftUI
import Carbon

class ShortcutManager {
    static let shared = ShortcutManager()
    
    private init() {}
}

extension ShortcutManager {
    enum Action: String {
        case fixGrammar
    }
    
    struct Shortcut: Codable {
        let key: String
        let modifier: NSEvent.ModifierFlags
        
        var description: String {
            var modifiers: [String] = []
            if modifier.contains(.command) { modifiers.append("⌘") }
            if modifier.contains(.option) { modifiers.append("⌥") }
            if modifier.contains(.control) { modifiers.append("⌃") }
            if modifier.contains(.shift) { modifiers.append("⇧") }
            return (modifiers + [key]).joined(separator: " + ")
        }
    }
}

extension NSEvent.ModifierFlags: Codable {}

extension Encodable {
    func toJSON() -> String {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self) else {
            return ""
        }
        return String(data: data, encoding: .utf8) ?? ""
    }
}

extension Decodable {
    static func fromJSON(_ jsonString: String) -> Self? {
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }
        let decoder = JSONDecoder()
        return try? decoder.decode(Self.self, from: data)
    }
}


extension KeyboardShortcut {
    init(from shortcut: ShortcutManager.Shortcut) {
        guard let firstCharacter = shortcut.key.first else {
            fatalError("Invalid key string")
        }
        let keyEquivalent = KeyEquivalent(.init(unicodeScalarLiteral: firstCharacter))
        self.init(keyEquivalent, modifiers: convert(flags: shortcut.modifier))
    }
    
}

private func convert(flags: NSEvent.ModifierFlags) -> SwiftUI.EventModifiers {
    var modifiers = EventModifiers([])
    if flags.contains(.command) { modifiers.insert(.command) }
    if flags.contains(.option) { modifiers.insert(.option) }
    if flags.contains(.control) { modifiers.insert(.control) }
    if flags.contains(.shift) { modifiers.insert(.shift) }
    return modifiers
}
