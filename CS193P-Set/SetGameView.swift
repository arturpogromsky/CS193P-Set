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
	@State private var angle = 0.0
	@State private var isDealing = true
  var body: some View {
		VStack {
			buttonsAndScore
			VStack {
				cards
				HStack {
					deck
					if !game.discardPile.isEmpty {
						Spacer()
					}
					discardPile
				}
			}
		}
    .padding(.horizontal, 10.0)
    .background {
      Color("Background")
        .ignoresSafeArea()
    }
  }
  
	func swing() {
		withAnimation(.easeOut(duration: Constants.swingDuration)) {
			angle = 30
		}
		withAnimation(.easeOut(duration: Constants.swingDuration).delay(Constants.swingDuration)) {
			angle = -30
		}
		withAnimation(.easeOut(duration: Constants.swingDuration).delay(2 * Constants.swingDuration)) {
			angle = 0
		}
	}
	
	var cards: some View {
		AspectVGrid(items: game.cardsToDisplay, aspectRatio: Constants.aspectRatio) { card in
			CardContent(card: card)
				.transition(.identity)
				.cardify(selectionStatus: card.selectionStatus, rotation: card.selectionStatus == .match ? 360 : 0)
				.rotation3DEffect(.degrees(card.selectionStatus == .mismatch ? angle : 0), axis: (0, 1, 0))
				.matchedGeometryEffect(id: card.id, in: dealingNameSpace)
				.padding(.all, 3.0)
				.onTapGesture {
					withAnimation(.easeOut(duration: Constants.animationDuration)) {
						game.choose(card)
					}
					swing()
				}
		}
	}
	
	var deck: some View {
		ZStack {
			ForEach(game.cardsInDeck.reversed()) { card in
				let index = game.cardsInDeck.firstIndex(of: card) ?? 0
				CardContent(card: card)
					.transition(.move(edge: .leading))
					.cardify(selectionStatus: card.selectionStatus, isFaceUp: false)
					.matchedGeometryEffect(id: card.id, in: dealingNameSpace)
					.offset(x: Constants.xOffset * CGFloat(index),
									y: Constants.yOffset * CGFloat(index))
			}
		}
		.aspectRatio(2/3, contentMode: .fit)
		.frame(height: Constants.deckHight)
		.onTapGesture {
			for i in 1...(wasDealt ? 3 : 12) {
				withAnimation(.easeOut(duration: Constants.animationDuration).delay(Double(i) * Constants.dealDelay)) {
					game.deal()
				}
			}
			wasDealt = true
		}
	}
	
	var discardPile: some View {
		ZStack {
			ForEach(game.discardPile.reversed()) { card in
				let index = game.discardPile.firstIndex(of: card) ?? 0
				CardContent(card: card)
					.transition(.move(edge: .trailing))
					.cardify(selectionStatus: card.selectionStatus, isFaceUp: false)
					.matchedGeometryEffect(id: card.id, in: dealingNameSpace)
					.offset(x: Constants.xOffset * CGFloat(index),
									y: Constants.yOffset * CGFloat(index))
			}
		}
		.aspectRatio(2/3, contentMode: .fit)
		.frame(height: Constants.deckHight)
	}
	
	var buttonsAndScore: some View {
		HStack {
			ButtonView(text: "Cheat") {
				withAnimation(.easeOut(duration: Constants.animationDuration)) {
					game.cheat()
				}
			}
			Text(String(game.score))
				.frame(minWidth: 90)
			ButtonView(text: "New") {
				withAnimation(.easeOut(duration: Constants.animationDuration)) {
					game.startNewGame()
					wasDealt = false
				}
			}
		}
		.frame(maxHeight: 35)
	}
	
	/// BUG: if `aspectRatio` = 2/3 and if there are 15 cards, then, when cards form set, 6 cards disappeare from screen instead of 3
	struct Constants {
		static let aspectRatio: CGFloat = 0.66
		static let animationDuration = 0.5
		static let dealDelay = 0.2
		static let swingDuration = 0.15
		static let deckHight: CGFloat = 120
		static let xOffset: CGFloat = -0.15
		static let yOffset: CGFloat = 0.15
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

