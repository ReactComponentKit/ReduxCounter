//
//  AppStore.swift
//  ReduxApp
//
//  Created by burt on 2021/02/04.
//

import Foundation
import Redux

// We can define the AppStore like as below but it is not a good design.
// If you add more state to the AppState, the AppStore becomes more massive store.
@available(*, deprecated, renamed: "ComposeAppState")
struct AppState: State {
    var count: Int = 0
    var content: Async<String> = .idle
}

@available(*, deprecated, renamed: "ComposeAppStore")
class AppStore: Store<AppState> {
    init() {
        super.init(state: AppState())
    }
    
    @Published
    var count: Int = 0
    
    @Published
    var content: Async<String> = .idle
    
    override func computed(new: AppState, old: AppState) {
        if (self.count != new.count) {
            self.count = new.count
        }
        
        if (self.content != new.content) {
            self.content = new.content
        }
    }
    
    override func worksAfterCommit() -> [(AppState) -> Void] {
        return [ { state in
            print(state.count)
        }]
    }
    
    private func INCREMENT(state: inout AppState, payload: Int) {
        state.count += payload
    }
    
    private func DECREMENT(state: inout AppState, payload: Int) {
        state.count -= payload
    }
    
    func incrementAction(payload: Int) {
        commit(mutation: INCREMENT, payload: payload)
    }
    
    func decrementAction(payload: Int) {
        commit(mutation: DECREMENT, payload: payload)
    }

    func fetchContent() async {
        do {
            commit { $0.content = .loading }
            let (data, _) = try await URLSession.shared.data(from: URL(string: "https://www.facebook.com")!)
            let value = String(data: data, encoding: .utf8) ?? ""
            commit { $0.content = .value(value: value) }
        } catch {
            commit { $0.content = .error(value: error) }
        }
    }
}
