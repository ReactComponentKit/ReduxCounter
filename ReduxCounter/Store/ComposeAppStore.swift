//
//  ComposeAppStore.swift
//  ReduxCounter
//
//  Created by burt on 2022/01/15.
//

import Foundation
import Redux

struct ComposeAppState: State {
    // A state that depends on the state of another store.
    var allLength: String = ""
}

class ComposeAppStore: Store<ComposeAppState> {
    let counter = CounterStore();
    let content = ContentStore();
    
    @Published
    private var count = 0;
    
    @Published
    private var isLoading = false;
    
    @Published
    private var contentValue: String? = nil;
    
    @Published
    private var error: String? = nil;
    
    @Published
    var allLength: String? = nil;
    
    override func computed(new: ComposeAppState, old: ComposeAppState) {
        if (new.allLength != old.allLength) {
            self.allLength = new.allLength
        }
    }
    
    init() {
        super.init(state: ComposeAppState())
        counter.$count.assign(to: &self.$count)
        content.$isLoading.assign(to: &self.$isLoading)
        content.$value.assign(to: &self.$contentValue)
        content.$error.assign(to: &self.$error)
    }
    
    // Examples of actions and state mutations that depend on the state and actions of other stores are
    private func SET_ALL_LENGTH(state: inout ComposeAppState, payload: String) {
        state.allLength = payload
    }
    func someComposeAction() async {
        await content.fetchContentValue()
        commit(mutation: SET_ALL_LENGTH, payload: "counter: \(counter.state.count), content: \(content.state.value?.count ?? 0)")
    }
}
