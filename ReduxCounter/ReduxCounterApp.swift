//
//  ReduxCounterApp.swift
//  ReduxCounter
//
//  Created by burt on 2021/02/04.
//

import SwiftUI
import Redux

@main
struct ReduxCounterApp: App {
    @StateObject
    private var store: AppStore = AppStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
