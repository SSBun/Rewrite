import Carbon
import SwiftUI

// MARK: - KeyboardShortcutRecorder

struct KeyboardShortcutRecorder: View {
    @Binding var shortcut: String
    @State private var isRecording: Bool = false
    
    var body: some View {
        HStack {
            Text(ShortcutManager.Shortcut.fromJSON(shortcut)!.description)
                .padding(.init(top: 5, leading: 10, bottom: 5, trailing: 10))
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            
            Button(action: {
                self.isRecording.toggle()
            }) {
                Text(isRecording ? "Save" : "Edit")
            }
            .keyboardShortcut(.defaultAction)
        }
        .onAppear {
            NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { event in
                if self.isRecording {
                    self.shortcut = keyEventToShortcut(event).toJSON()
                }
                return event
            }
        }
    }
    
    private func keyEventToShortcut(_ event: NSEvent) -> ShortcutManager.Shortcut {
        let key = event.charactersIgnoringModifiers?.uppercased() ?? ""
        let modifier = event.modifierFlags
        return ShortcutManager.Shortcut(key: key, modifier: modifier)
    }
}
