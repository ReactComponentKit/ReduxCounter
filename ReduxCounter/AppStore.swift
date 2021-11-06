//
//  AppStore.swift
//  ReduxApp
//
//  Created by burt on 2021/02/04.
//

import Foundation
import Redux

struct AppState: State {
    var count: Int = 0
    var content: String? = nil
    var error: String? = nil
}

class AppStore: Store<AppState> {
    
    init() {
        super.init(state: AppState())
    }
    
    @Published
    var count: Int = 0
    
    @Published
    var content: String? = nil
    
    @Published
    var error: String? = nil
    
    override func computed(new: AppState, old: AppState) {
        self.count = new.count;
        if let content = new.content {
            self.content = content
        }
        if let error = new.error {
            self.error = error
        }
    }
    
    override func worksBeforeCommit() -> [(inout AppState) -> Void] {
        return [ { (mutableState) in
            mutableState.error = nil
        }]
    }
    
    override func worksAfterCommit() -> [(inout AppState) -> Void] {
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
    
    private func SET_CONTENT(state: inout AppState, payload: String) {
        state.content = payload
    }
    
    private func SET_ERROR(state: inout AppState, payload: String) {
        state.error = payload
    }
    
    func incrementAction(payload: Int) {
        commit(mutation: INCREMENT, payload: payload)
    }
    
    func decrementAction(payload: Int) {
        commit(mutation: DECREMENT, payload: payload)
    }
    
    func fetchContent() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: URL(string: "https://www.google.com")!)
            let value = String(data: data, encoding: .utf8) ?? ""
            commit(mutation: SET_CONTENT, payload: value)
        } catch {
            commit(mutation: SET_ERROR, payload: error.localizedDescription)
        }
    }
}
