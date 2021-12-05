//
//  SetGameView.swift
//  Set
//
//  Created by Артур Погромский on 23.11.2021.
//

import SwiftUI

struct SetGameView: View {
  @ObservedObject var game: SetGameViewModel
  var body: some View {
    VStack {
      AspectVGrid(items: game.cards, aspectRatio: Constants.aspectRatio) { card in
        CardView(viewModel: game, card: card)
          .padding(.all, 3.0)
          .onTapGesture {
            game.choose(card)
          }
      }
      .animation(.easeInOut(duration: 0.75), value: game.cards)
      
      HStack {
        Text("Score: \(game.score)")
          .font(.title3)
        ButtonView(text: "Add cards") {
          game.addCards()
        }
        ButtonView(text: "New") {
          game.startNewGame()
        }
        ButtonView(text: "Cheat") {
          game.cheat()
        }
      }
      .frame(maxHeight: 35)
    }
    .padding([.top, .leading, .trailing], 35.0)
    .background {
      Color("Background")
        .ignoresSafeArea()
    }
  }
  
  ///BUG: if `aspectRatio` = 2/3 and if there are 15 cards, then, when cards form set, 6 cards disappeare from screen instead of 3
  struct Constants {
    static let aspectRatio: CGFloat = 0.66
  }
}

struct ButtonView: View {
  let text: String
  let action: () -> ()
  let roundedRectangle = RoundedRectangle(cornerRadius: Constants.cornerRadius)
  var body: some View {
    Button {
      action()
    } label: {
      roundedRectangle
        .strokeBorder(lineWidth: 2)
        .overlay(Text(text))
        .background(content: {
          roundedRectangle
            .foregroundColor(.white)
        })
        .foregroundColor(.black)
    }
    
  }
  
  struct Constants {
    static let cornerRadius: CGFloat = 10
  }
}















struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      SetGameView(game: SetGameViewModel())
    }
  }
}

