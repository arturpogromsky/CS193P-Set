//
//  StartScreen.swift
//  Set
//
//  Created by Артур Погромский on 03.12.2021.
//

import SwiftUI

struct StartScreen: View {
  @ObservedObject var game: SetGameViewModel
  @State var gameIsActive = false
  var body: some View {
    NavigationView {
      VStack {
        NavigationLink {
          SetGameView(game: game)
            .navigationBarHidden(true)
        } label: {
          Text("1 player")
        }
        .navigationBarHidden(true)
        .padding()

        Text("2 players")
        Text("3 players")
        Text("4 players")
      }
    }
  }
}











struct StartScreen_Previews: PreviewProvider {
  static let game = SetGameViewModel()
  static var previews: some View {
    StartScreen(game: game)
  }
}
