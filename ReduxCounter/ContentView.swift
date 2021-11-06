//
//  ContentView.swift
//  ReduxCounter
//
//  Created by burt on 2021/02/04.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject
    private var store: AppStore
    
    var body: some View {
        
        VStack {
            Text("\(store.count)")
                .font(.title)
                .bold()
                .padding()
            if let error = store.error {
                Text("Error! \(error)")
            }
            HStack {
                Spacer()
                
                Button(action: { store.decrementAction(payload: 1) }) {
                    Text(" - ")
                        .font(.title)
                        .bold()
                }
                
                Spacer()
                
                Button(action: { store.incrementAction(payload: 1) }) {
                    Text(" + ")
                        .font(.title)
                        .bold()
                }
                
                Spacer()
                
            }
            VStack {
                Button(action: {
                    Task {
                        await store.fetchContent()
                    }
                }) {
                    Text("Fetch Content")
                        .bold()
                        .multilineTextAlignment(.center)
                }
                ScrollView(.vertical) {
                    Text(store.content ?? "")
                }
                .frame(width: UIScreen.main.bounds.width)
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

