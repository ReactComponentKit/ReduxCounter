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

func fetchContent(state: AppState, action: Action, sideEffect: @escaping SideEffect) {
    var (dispatch, cancellable) = sideEffect()
    URLSession.shared.dataTaskPublisher(for: URL(string: "https://www.google.com")!)
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.global())
        .sink { (completion) in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                dispatch(UpdateContentAction(content: .failed(error: error)))
            }
        } receiveValue: { (data, response) in
            let value = String(data: data, encoding: .utf8) ?? ""
            dispatch(UpdateContentAction(content: .success(value: value)))
        }
        .store(in: &cancellable)
}

func asyncJob(state: AppState, action: Action, sideEffect: @escaping SideEffect) {
    let (dispatcher, _) = sideEffect()
    Thread.sleep(forTimeInterval: 2)
    dispatcher(IncrementAction(payload: 2))
}

func asyncJobWithError(state: AppState, action: Action, sideEffect: @escaping SideEffect) throws {
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

func updateContent(state: AppState, action: Action) -> AppState {
    guard let action = action as? UpdateContentAction else { return state }
    return state.copy { mutation in
        mutation.content = action.content
    }
}

struct AsyncIncrementAction: Action {
    static var job: ActionJob {
        Job<AppState>(middleware: [asyncJob])
    }
}

struct IncrementAction: Action {
    let payload: Int
    init(payload: Int = 1) {
        self.payload = payload
    }
    
    static var job: ActionJob {
        Job<AppState>(reducers: [counterReducer]) { state, newState in
            state.count = newState.count
        }
    }
}

struct DecrementAction: Action {
    let payload: Int
    init(payload: Int = 1) {
        self.payload = payload
    }
    
    static var job: ActionJob {
        Job(reducers: [counterReducer]) { state, newState in
            state.count = newState.count
        }
    }
}

struct TestAsyncErrorAction: Action {
    static var job: ActionJob {
        Job<AppState>(middleware: [asyncJobWithError])
    }
}

struct RequestContentAction: Action {
    static var job: ActionJob {
        Job<AppState>(middleware: [fetchContent])
    }
}

struct UpdateContentAction: Action {
    let content: Async<String>
    
    static var job: ActionJob {
        Job<AppState>(reducers: [updateContent]) { (state, newState) in
            state.content = newState.content
        }
    }
}

struct AppState: State {
    var count: Int = 0
    var content: Async<String> = .uninitialized
    var error: (Error, Action)?
}

class AppStore: Store<AppState> {
    override func afterProcessingAction(state: AppState, action: Action) {
        print("[## \(type(of: action)) ##]")
        print(state)
    }
}
