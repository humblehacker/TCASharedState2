import ComposableArchitecture
import SwiftUI

@main
struct TCASharedState2App: App {
    var body: some Scene {
        WindowGroup {
            ExampleView(store: Store(initialState: Example.State()) {
                Example()._printChanges()
            })
        }
    }
}
