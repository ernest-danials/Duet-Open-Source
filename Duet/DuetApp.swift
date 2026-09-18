import SwiftUI
import FoundationModels

@main
struct DuetApp: App {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    private let model = SystemLanguageModel.default
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                switch self.model.availability {
                case .available:
                    ContentView()
                        .environment(StepManager())
                        .environment(UserInputManager())
                case .unavailable(.deviceNotEligible):
                    VStack {
                        ContentUnavailableView("Apple Intelligence Not Supported", systemImage: "apple.intelligence.badge.xmark", description: Text("Duet is unavailable because this device does not support Apple Intelligence."))
                    }
                    .alignView(to: .center)
                    .alignViewVertically(to: .center)
                    .background(colorScheme == .light ? Color("Cream") : Color("CharcoalMist"))
                case .unavailable(.appleIntelligenceNotEnabled):
                    VStack {
                        ContentUnavailableView("Apple Intelligence Not Enabled", systemImage: "apple.intelligence.badge.xmark", description: Text("Duet is unavailable because Apple Intelligence has not been turned on."))
                    }
                    .alignView(to: .center)
                    .alignViewVertically(to: .center)
                    .background(colorScheme == .light ? Color("Cream") : Color("CharcoalMist"))
                case .unavailable(.modelNotReady):
                    VStack {
                        ContentUnavailableView("Apple Intelligence Not Ready Yet", systemImage: "apple.intelligence.badge.xmark", description: Text("Duet is unavailable because Apple Intelligence is not ready yet. Try again later."))
                    }
                    .alignView(to: .center)
                    .alignViewVertically(to: .center)
                    .background(colorScheme == .light ? Color("Cream") : Color("CharcoalMist"))
                case .unavailable(_):
                    VStack {
                        ContentUnavailableView("Apple Intelligence Not Supported", systemImage: "apple.intelligence.badge.xmark", description: Text("Duet is unavailable because this device does not support Apple Intelligence."))
                    }
                    .alignView(to: .center)
                    .alignViewVertically(to: .center)
                    .background(colorScheme == .light ? Color("Cream") : Color("CharcoalMist"))
                }
            }
            .frame(minWidth: 700, minHeight: 700)
        }
        .windowResizability(.contentMinSize)
    }
}
