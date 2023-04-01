//
//  WebBrowserView.swift
//  V2er
//
//  Created by GARY on 2023/4/1.
//  Copyright © 2023 lessmore.io. All rights reserved.
//

import SwiftUI
import WebView

struct WebBrowserView: View {
  @StateObject var webViewStore = WebViewStore()
  let url: String
  
  var body: some View {
    WebView(webView: webViewStore.webView)
      .navigationBarTitle(Text(verbatim: webViewStore.title ?? ""), displayMode: .inline)
      .navigationBarItems(trailing: HStack {
        Button {
          webViewStore.webView.goBack()
        } label: {
          Image(systemName: "chevron.left")
            .imageScale(.large)
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32)
        }
        .disabled(!webViewStore.canGoBack)
        
        Button {
          webViewStore.webView.goForward()
        } label: {
          Image(systemName: "chevron.right")
            .imageScale(.large)
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32)
        }
        .disabled(!webViewStore.canGoForward)
      })
      .onAppear {
        self.webViewStore.webView.load(URLRequest(url: URL(string: self.url)!))
      }
  }
  
}
