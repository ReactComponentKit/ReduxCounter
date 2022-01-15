//
//  ContentStore.swift
//  ReduxCounter
//
//  Created by burt on 2022/01/15.
//

import Foundation
import Redux

struct Content: State {
    var value: String? = nil
    var error: String? = nil
}

class ContentStore: Store<Content> {
    @Published
    var value: String? = nil
    
    @Published
    var error: String? = nil
    
    override func computed(new: Content, old: Content) {
        if (self.value != new.value) {
            self.value = new.value
        }
        
        if (self.error != new.error) {
            self.error = new.error
        }
    }
    
    init() {
        super.init(state: Content())
    }
    
    override func worksAfterCommit() -> [(Content) -> Void] {
        return [
            { state in
                print(state.value ?? "없음")
            }
        ]
    }
    
    private func SET_CONTENT_VALUE(state: inout Content, payload: String) {
        state.value = payload
    }
    
    private func SET_ERROR(state: inout Content, payload: String?) {
        state.error = payload
    }
    
    func fetchContentValue() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: URL(string: "https://www.facebook.com")!)
            let value = String(data: data, encoding: .utf8) ?? ""
            commit(mutation: SET_ERROR, payload: nil)
            commit(mutation: SET_CONTENT_VALUE, payload: value)
        } catch {
            commit(mutation: SET_ERROR, payload: error.localizedDescription)
        }
    }
}
