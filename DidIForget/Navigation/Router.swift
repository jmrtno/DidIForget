import SwiftUI
import Combine

@MainActor
final class Router: ObservableObject {
    @Published var navigationPath: [Route] = []
    
    func push(_ route: Route) {
        navigationPath.append(route)
    }
    
    func pop() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }
    
    func popToRoot() {
        navigationPath.removeAll()
    }
    
    func replace(with routes: [Route]) {
        navigationPath = routes
    }
}
