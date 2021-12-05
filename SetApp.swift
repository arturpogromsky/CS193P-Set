//
//  SetApp.swift
//  Set
//
//  Created by Артур Погромский on 23.11.2021.
//

import SwiftUI

@main
struct SetApp: App {
  let game = SetGameViewModel()
  var body: some Scene {
    WindowGroup {
      SetGameView(game: game)
    }
  }
}
