//
//  ContentView.swift
//  ReduxCounter
//
//  Created by burt on 2021/02/04.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject
    private var store: ComposeAppStore
    
    var body: some View {
        
        VStack {
            Text("\(store.counter.count)")
                .font(.title)
                .bold()
                .padding()
            if let error = store.content.error {
                Text("Error! \(error)")
            }
            HStack {
                Spacer()
                
                Button(action: { store.counter.decrementAction(payload: 1) }) {
                    Text(" - ")
                        .font(.title)
                        .bold()
                }
                
                Spacer()
                
                Button(action: { store.counter.incrementAction(payload: 1) }) {
                    Text(" + ")
                        .font(.title)
                        .bold()
                }
                
                Spacer()
                
            }
            VStack {
                Button(action: {
                    Task {
                        await store.someComposeAction()
                    }
                }) {
                    Text("All Length")
                        .bold()
                        .multilineTextAlignment(.center)
                }
                Text(store.allLength ?? "")
                    .foregroundColor(.red)
                    .font(.system(size: 12))
                    .lineLimit(5)
                
                Button(action: {
                    Task {
                        await store.content.fetchContentValue()
                    }
                }) {
                    Text("Fetch Content")
                        .bold()
                        .multilineTextAlignment(.center)
                }
                Text(store.content.value ?? "")
                    .foregroundColor(.red)
                    .font(.system(size: 12))
                    .lineLimit(5)
            }
        }
        .padding(.horizontal, 100)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

