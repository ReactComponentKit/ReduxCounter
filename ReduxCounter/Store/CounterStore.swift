//
//  CounterStore.swift
//  ReduxCounter
//
//  Created by burt on 2022/01/15.
//

import Foundation
import Redux

struct Counter: State {
    var count: Int = 0
}

class CounterStore: Store<Counter> {
    @Published
    var count: Int = 0
    
    override func computed(new: Counter, old: Counter) {
        if (self.count != new.count) {
            self.count = new.count
        }
    }
    
    init() {
        super.init(state: Counter())
    }
    
    override func worksAfterCommit() -> [(Counter) -> Void] {
        return [ { state in
            print(state.count)
        }]
    }
    
    private func INCREMENT(state: inout Counter, payload: Int) {
        state.count += payload
    }
    
    private func DECREMENT(state: inout Counter, payload: Int) {
        state.count -= payload
    }
    
    func incrementAction(payload: Int) {
        commit(mutation: INCREMENT, payload: payload)
    }
    
    func decrementAction(payload: Int) {
        commit(mutation: DECREMENT, payload: payload)
    }
}
