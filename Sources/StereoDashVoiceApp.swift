import SwiftUI

@main
struct StereoDashVoiceApp: App {
    @StateObject private var model = ConversationModel()

    var body: some Scene {
        WindowGroup {
            ConversationView()
                .environmentObject(model)
        }
    }
}
