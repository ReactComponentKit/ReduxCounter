//
//  ContentStore.swift
//  ReduxCounter
//
//  Created by burt on 2022/01/15.
//

import Foundation
import Redux

struct Content: State {
    var value: Async<String> = .idle
}

class ContentStore: Store<Content> {
    @Published
    var value: Async<String> = .idle
    
    override func computed(new: Content, old: Content) {
        if new.value != old.value {
            self.value = new.value
        }
    }
    
    init() {
        super.init(state: Content())
    }
    
    override func worksAfterCommit() -> [(Content) -> Void] {
        return [
            { state in
                print(state.value)
            }
        ]
    }
    
    func fetchContentValue() async {
        do {
            commit { $0.value = .loading }
            let (data, _) = try await URLSession.shared.data(from: URL(string: "https://www.facebook.com")!)
            let value = String(data: data, encoding: .utf8) ?? ""
            commit { $0.value = .value(value: value) }
        } catch {
            commit { $0.value = .error(value: error) }
        }
    }
}
