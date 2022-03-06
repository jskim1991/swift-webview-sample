//
//  WebViewModel.swift
//  webview-test
//
//  Created by Jaesik Kim on 2022/03/04.
//

import Foundation
import Combine

class WebViewModel : ObservableObject {
    
    // Title of the HTML page
    var webTitle = PassthroughSubject<String, Never>()
    
    // Javascript to iOS
    var showAlert = PassthroughSubject<Bool, Never>()
    
    // iOS to Javascript
    var callbackValueFromNative = PassthroughSubject<String, Never>()
}
