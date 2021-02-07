//
//  AppStore.swift
//  ReduxApp
//
//  Created by burt on 2021/02/04.
//

import Foundation
import Redux

enum MyError: Error {
    case tempError
}

func asyncJob(state: AppState, action: Action, dispatcher: @escaping ActionDispatcher) {
    Thread.sleep(forTimeInterval: 2)
    dispatcher(IncrementAction(payload: 2))
}

func asyncJobWithError(state: AppState, action: Action, dispatcher: @escaping ActionDispatcher) throws {
    Thread.sleep(forTimeInterval: 2)
    throw MyError.tempError
}

func counterReducer(state: AppState, action: Action) -> AppState {
    return state.copy { mutation in
        switch action {
        case let act as IncrementAction:
            mutation.count += act.payload
        case let act as DecrementAction:
            mutation.count -= act.payload
        default:
            break
        }
    }
}

struct AsyncIncrementAction: Action {
}

struct IncrementAction: Action {
    let payload: Int
    init(payload: Int = 1) {
        self.payload = payload
    }
}

struct DecrementAction: Action {
    let payload: Int
    init(payload: Int = 1) {
        self.payload = payload
    }
}

struct TestAsyncErrorAction: Action {
}

struct AppState: State {
    var count: Int = 0
    var error: (Error, Action)?
}

class AppStore: Store<AppState> {
    override func afterProcessingAction(state: AppState, action: Action) {
        print("[## \(type(of: action)) ##]")
        print(state)
    }
    
    override func registerJobs() {
        process(action: AsyncIncrementAction.self) {
            Job(middleware: [asyncJob])
        }
        
        process(action: IncrementAction.self) {
            Job(reducers: [counterReducer]) { state, newState in
                state.count = newState.count
            }
        }
        
        process(action: DecrementAction.self) {
            Job(reducers: [counterReducer]) { state, newState in
                state.count = newState.count
            }
        }
        
        process(action: TestAsyncErrorAction.self) {
            Job(middleware: [asyncJobWithError])
        }
    }
}
