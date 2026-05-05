import SwiftUI
import Combine

class AppState: ObservableObject {
    // Whether the iPhone companion app has completed setup
    @Published var isSetupComplete: Bool = false

    // Time goal set by user (in seconds). nil = no goal set yet.
    @Published var timeGoalSeconds: Int? = nil

    // For demo/preview purposes, you can toggle this to simulate setup complete
    func markSetupComplete() {
        isSetupComplete = true
    }
}
