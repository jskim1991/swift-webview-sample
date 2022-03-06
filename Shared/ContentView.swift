//
//  ContentView.swift
//  Shared
//
//  Created by Jaesik Kim on 2022/03/04.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var viewModel = WebViewModel()
    @State var bar = false
    @State var webTitle : String = ""
    @State var showAlert : Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    SwiftUIWebView(url: URL(string: "http://localhost:3000"), viewModel: viewModel)
                }
                .navigationBarTitle(Text(webTitle), displayMode: .inline)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Hello"), message: Text("Alert from React"), dismissButton: .default(Text("OK"), action: {
                        self.showAlert = false
                        self.viewModel.callbackValueFromNative.send(UUID().uuidString)
                    }))
                }
                .onReceive(self.viewModel.webTitle, perform: { receivedTitle in
                    self.webTitle = receivedTitle
                })
                .onReceive(self.viewModel.showAlert, perform: {result in
                    self.showAlert = result
                })
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
