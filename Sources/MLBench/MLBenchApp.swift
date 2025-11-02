import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        
        DispatchQueue.main.async {
            if let window = NSApp.windows.first {
                window.isMovableByWindowBackground = true // make whole window draggable
                window.styleMask.remove(.resizable) 
                window.standardWindowButton(.zoomButton)?.isHidden = true
            }
        }
    }
}

@main
struct MLBenchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Window("MLBench", id: "main") {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {

            // remove the menu
            CommandGroup(replacing: .newItem) { }
            CommandGroup(replacing: .undoRedo) { }
            CommandGroup(replacing: .pasteboard) { }
            CommandGroup(replacing: .toolbar) { }
            CommandGroup(replacing: .windowArrangement) { }
            CommandGroup(replacing: .windowList) { }
            CommandGroup(replacing: .help) { }
            
            // prefs & quit
            CommandGroup(replacing: .appInfo) {
                Button("Preferences...") {
                    NotificationCenter.default.post(name: .showPreferences, object: nil)
                }.keyboardShortcut(",", modifiers: .command)
            }
            
            CommandGroup(replacing: .appTermination) {
                 Button("Quit MLBench") {
                     NSApplication.shared.terminate(nil)
                 }.keyboardShortcut("q", modifiers: .command)
            }
        }
    }
}