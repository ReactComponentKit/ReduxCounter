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
            if store.error != nil {
                Text("Error!")
            }
            HStack {
                Button(action: { store.dispatch(action: DecrementAction()) }) {
                    Text(" - ")
                        .font(.title)
                        .bold()
                }
                
                Spacer()
                
                Button(action: {
                    // You can dispatch action in this style
                    // store.dispatch(action: IncrementAction())
                    // or below style.
                    store.dispatch(\.count, payload: 1) { (state, value) -> AppState in
                        return state.copy { mutation in
                            mutation.count += value
                        }
                    }
                }) {
                    Text(" + ")
                        .font(.title)
                        .bold()
                }
                
                Spacer()
                
                Button(action: { store.dispatch(action: AsyncIncrementAction()) }) {
                    Text("Async +")
                        .bold()
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                Button(action: { store.dispatch(action: TestAsyncErrorAction()) }) {
                    Text(" Async with Error ")
                        .bold()
                        .multilineTextAlignment(.center)
                }
            }
            VStack {
                Button(action: { store.dispatch(action: RequestContentAction()) }) {
                    Text("Fetch Content")
                        .bold()
                        .multilineTextAlignment(.center)
                }
                ScrollView(.vertical) {
                    Text(store.content.value ?? store.content.error?.localizedDescription ?? "")
                }
                .frame(width: UIApplication.shared.windows.first?.frame.width)
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

