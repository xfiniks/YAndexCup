import SwiftUI

@main
struct DrawieApp: App {
    var body: some Scene {
        WindowGroup {
            CanvasMenu()
                .environmentObject(DrawingSettings())
                .environmentObject(Sketch())
        }
    }
}
