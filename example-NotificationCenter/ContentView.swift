//
//  ContentView.swift
//  example-NotificationCenter
//
//  Created by Muukii on 2024/12/25.
//

import SwiftUI

struct ContentView: View {
  var body: some View {
    ZStack {
      Color.purple
        .ignoresSafeArea()
      BookNotificationCenter()
    }
  }
}

#Preview {
  ContentView()
}
