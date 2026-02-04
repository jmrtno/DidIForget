import SwiftUI

struct AppCoordinator: View {
    @StateObject private var router: Router
    private let viewFactory: RouteViewFactory
    
    init(dependencies: AppDependencies) {
        _router = StateObject(wrappedValue: Router())
        self.viewFactory = RouteViewFactory(dependencies: dependencies)
    }
    
    var body: some View {
        NavigationStack(path: $router.navigationPath) {
            viewFactory.view(for: .reminderList)
                .navigationDestination(for: Route.self) { route in
                    viewFactory.view(for: route)
                }
        }
        .environmentObject(router)
    }
}
