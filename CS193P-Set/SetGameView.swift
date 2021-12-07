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
          withAnimation(.easeOut(duration: Constants.animationDuration)) {
            game.deal()
          }
        }

        ButtonView(text: "Cheat") {
          withAnimation(.easeOut(duration: Constants.animationDuration)) {
            game.cheat()
          }
        }
        ButtonView(text: "New") {
          withAnimation(.easeOut(duration: Constants.animationDuration)) {
            game.startNewGame()
            wasDealt = false
          }
        }
      }
				.frame(maxHeight: 35)
      ZStack(alignment: .bottom) {
        AspectVGrid(items: game.cardsToDisplay, aspectRatio: Constants.aspectRatio) { card in
          CardContent(card: card)
						.transition(.identity)
						.cardify(selectionStatus: card.selectionStatus, rotation: card.selectionStatus == .match ? 360 : 0)
            .matchedGeometryEffect(id: card.id, in: dealingNameSpace)
            .padding(.all, 3.0)
            .onTapGesture {
							withAnimation(.easeOut(duration: Constants.animationDuration)) {
                game.choose(card)
              }
            }

        }
        
        HStack {
          ZStack {
            ForEach(game.cardsInDeck.reversed()) { card in
              CardContent(card: card)
								.transition(.identity)
								.cardify(selectionStatus: card.selectionStatus, isFaceUp: false)
//								.transition(.modifier(active: Cardify(selectionStatus: card.selectionStatus,
//																											isFaceUp: true),
//																			identity: Cardify(selectionStatus: card.selectionStatus,
//																												isFaceUp: false)))
                .matchedGeometryEffect(id: card.id, in: dealingNameSpace)
							

                
            }
          }
          .aspectRatio(2/3, contentMode: .fit)
          .frame(height: 150)
          .onTapGesture {
            for i in 1...(wasDealt ? 3 : 12) {
							withAnimation(.easeOut(duration: Constants.animationDuration).delay(Double(i) * Constants.dealDelay)) {
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
              CardContent(card: card)
								.transition(.identity)
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
		static let animationDuration = 0.5
		static let dealDelay = 0.2
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

