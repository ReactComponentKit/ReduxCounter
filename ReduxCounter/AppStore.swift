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
        if (self.count != new.count) {
            self.count = new.count
        }
        
        if (self.content != new.content) {
            self.content = new.content
        }
        
        if (self.error != new.error) {
            self.error = new.error
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
    
    private func SET_CONTENT(state: inout AppState, payload: String) {
        state.content = payload
    }
    
    private func SET_ERROR(state: inout AppState, payload: String?) {
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
            let (data, _) = try await URLSession.shared.data(from: URL(string: "https://www.facebook.com")!)
            let value = String(data: data, encoding: .utf8) ?? ""
            commit(mutation: SET_ERROR, payload: nil)
            commit(mutation: SET_CONTENT, payload: value)
        } catch {
            commit(mutation: SET_ERROR, payload: error.localizedDescription)
        }
    }
}
