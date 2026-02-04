import SwiftUI

@main
struct DidIForgetApp: App {
    private let dependencies = AppDependencies()
    
    var body: some Scene {
        WindowGroup {
            AppCoordinator(dependencies: dependencies)
        }
    }
}
