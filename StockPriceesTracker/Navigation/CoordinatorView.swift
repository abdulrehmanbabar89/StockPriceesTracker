import SwiftUI

struct CoordinatorView: View {
    @Bindable var coordinator: AppCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.rootView()
                .navigationDestination(for: AppRoute.self) { route in
                    coordinator.destination(for: route)
                }
        }
        .environment(coordinator)
    }
}
