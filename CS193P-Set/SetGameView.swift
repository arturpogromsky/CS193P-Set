//
//  SetGameView.swift
//  Set
//
//  Created by Артур Погромский on 23.11.2021.
//

import SwiftUI

struct SetGameView: View {
  @ObservedObject var game: SetGameViewModel
  @Namespace var dealingNameSpace
  @State private var wasDealt = false
  var body: some View {
    VStack {
      HStack {
        ButtonView(text: "Deal") {
          withAnimation(.easeOut(duration: 1)) {
            game.deal()
          }
        }
        ButtonView(text: "Flip") {
          withAnimation(.linear(duration: 1)) {
            game.model.flip()

          }
        }
        ButtonView(text: "Cheat") {
          withAnimation(.easeOut(duration: 5)) {
            game.cheat()
          }
        }
        ButtonView(text: "New") {
          withAnimation(.easeOut(duration: 1)) {
            game.startNewGame()
            wasDealt = false
          }
        }
      }
      .frame(maxHeight: 35)
      ZStack(alignment: .bottom) {
        AspectVGrid(items: game.cardsToDisplay, aspectRatio: Constants.aspectRatio) { card in
          Content(card: card)
            .cardify(selectionStatus: card.selectionStatus, isFaceUp: true)
            .matchedGeometryEffect(id: card.id, in: dealingNameSpace, isSource: false)
            .padding(.all, 3.0)

            .onTapGesture {
              withAnimation(.linear(duration: 3)) {
                game.choose(card)
//                let index = game.model.deck.allCards.firstIndex(where: { $0.id == card.id })!
//                game.model.deck[index].isFaceUp.toggle()
              }
            }
            
        }
        .onAppear {
          print("Я родился")
        }
        
        HStack {
          ZStack {
            ForEach(game.cardsInDeck.reversed()) { card in
              Content(card: card)
                .cardify(selectionStatus: card.selectionStatus, isFaceUp: false)
                .matchedGeometryEffect(id: card.id, in: dealingNameSpace, isSource: true)

                
            }
          }
          .aspectRatio(2/3, contentMode: .fit)
          .frame(height: 150)
          .onTapGesture {
            for i in 1...(wasDealt ? 3 : 12) {
              withAnimation(.easeOut(duration: 1).delay(Double(i) * 0.2)) {
                game.deal()
              }
            }
            wasDealt = true
          }
          
          if game.discardPile.count != 0 {
            Spacer()
          }

          ZStack {
            ForEach(game.discardPile) { card in
              Content(card: card)
                .cardify(selectionStatus: card.selectionStatus, isFaceUp: false)
                .matchedGeometryEffect(id: card.id, in: dealingNameSpace)
            }
          }
          .aspectRatio(2/3, contentMode: .fit)
          .frame(height: 150)
        }
      }
    }
    .padding(.horizontal, 10.0)
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

//struct FlipTransiion: ViewModifier {
//  var degrees: Double
//  func body(content: Content) -> some View {
//    content
//      .rotation3DEffect(.degrees(degrees), axis: (0, 1, 0))
//  }
//}











struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      SetGameView(game: SetGameViewModel())
    }
  }
}

