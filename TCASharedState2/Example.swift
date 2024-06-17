import ComposableArchitecture
import SwiftUI

struct ExampleView: View {
    @Bindable var store: StoreOf<Example>

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Child1View(store: store.scope(state: \.child1, action: \.child1))
            Child2View(store: store.scope(state: \.child2, action: \.child2))
        }
    }
}

private struct Child1View: View {
    let store: StoreOf<Example.Child1>

    var body: some View {
        VStack(alignment: .leading) {
            Text("value: \(String(describing: store.value))")
            Button("Toggle") { store.send(.toggle) }
        }
    }
}

private struct Child2View: View {
    let store: StoreOf<Example.Child2>

    var body: some View {
        Text("value: \(store.value)")
    }
}

// MARK: Reducers

@Reducer
struct Example {
    @ObservableState
    struct State: Equatable {
        var child1 = Child1.State()
        var child2 = Child2.State()
    }

    enum Action {
        case child1(Child1.Action)
        case child2(Child2.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.child1, action: \.child1) { Child1() }
        Scope(state: \.child2, action: \.child2) { Child2() }

        Reduce { state, action in
            switch action {
            case .child1, .child2:
                return .none
            }
        }
    }

    @Reducer
    struct Child1 {
        @ObservableState
        struct State: Equatable {
            @Shared(.appStorage("child1Value")) var value: Int? = nil
        }

        enum Action {
            case toggle
        }

        var body: some Reducer<State, Action> {
            Reduce { state, action in
                switch action {
                case .toggle:
                    return .run { [value = state.$value] send in
                        value.withLock { $0 = $0 == nil ? 0 : nil }
                    }
                }
            }
        }
    }

    @Reducer
    struct Child2 {
        @ObservableState
        struct State: Equatable {
            @Shared(.appStorage("child2Value")) var value = 1
        }

        enum Action {}
    }
}

#Preview {
    ExampleView(
        store: Store(initialState: Example.State()) { Example() }
    )
}

