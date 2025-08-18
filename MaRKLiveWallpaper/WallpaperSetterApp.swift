import SwiftUI

@main
struct LiveWallpaperApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 400, idealWidth: 450, minHeight: 500, idealHeight: 550)
        }
        .windowStyle(DefaultWindowStyle())
        .windowResizability(.contentSize)
    }
}
