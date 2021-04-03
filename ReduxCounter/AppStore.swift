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

func fetchContent(state: AppState, action: Action, sideEffect: @escaping SideEffect<AppState>) {
    let (_, ctx) = sideEffect()
    guard
        let context = ctx,
        let store: AppStore = context.store()
    else {
        return
    }
    
    print(store.sharedVariableAmongMiddlewares)
    
    context.updateAsync(\.content, payload: .loading)
    URLSession.shared.dataTaskPublisher(for: URL(string: "https://www.google.com")!)
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.global())
        .sink { (completion) in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                context.updateAsync(\.content, payload: .failed(error: error))
            }
        } receiveValue: { (data, response) in
            let value = String(data: data, encoding: .utf8) ?? ""
            context.updateAsync(\.content, payload: .success(value: value))
        }
        .cancel(with: context.cancelBag)
}

func asyncJob(state: AppState, action: Action, sideEffect: @escaping SideEffect<AppState>) {
    let (dispatcher, _) = sideEffect()
    Thread.sleep(forTimeInterval: 2)
    dispatcher(IncrementAction(payload: 2))
}

func asyncJobWithError(state: AppState, action: Action, sideEffect: @escaping SideEffect<AppState>) {
    Thread.sleep(forTimeInterval: 2)
    let (_, context) = sideEffect()
    context?.dispatch(\.error, payload: (MyError.tempError, action)) { (state, error) -> AppState in
        return state.copy { mutable in
            mutable.error = error
        }
    }
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
    var job: ActionJob {
        Job<AppState>(middleware: [asyncJob])
    }
}

struct IncrementAction: Action {
    let payload: Int
    init(payload: Int = 1) {
        self.payload = payload
    }
    
    var job: ActionJob {
        Job<AppState>(keyPath: \.count, reducers: [counterReducer])
    }
}

struct DecrementAction: Action {
    let payload: Int
    init(payload: Int = 1) {
        self.payload = payload
    }
    
    var job: ActionJob {
        Job(keyPath: \.count, reducers: [counterReducer])
    }
}

struct TestAsyncErrorAction: Action {
    var job: ActionJob {
        Job<AppState>(middleware: [asyncJobWithError])
    }
}

struct RequestContentAction: Action {
    var job: ActionJob {
        Job<AppState>(middleware: [fetchContent])
    }
}

struct AppState: State {
    var count: Int = 0
    var content: Async<String> = .uninitialized
    var error: (Error, Action)?
}

class AppStore: Store<AppState> {
    internal var sharedVariableAmongMiddlewares: String = "Hello Middleware!"
    
    override func beforeProcessingAction(state: AppState, action: Action) -> (AppState, Action)? {
        return (
            state.copy({ mutation in
                mutation.error = nil
            }),
            action
        )
    }
    
    override func afterProcessingAction(state: AppState, action: Action) {
        print("[## \(type(of: action)) ##]")
        print(state)
    }
}
