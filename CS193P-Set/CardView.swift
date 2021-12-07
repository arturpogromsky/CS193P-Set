//
//  CardView.swift
//  Set
//
//  Created by Артур Погромский on 26.11.2021.
//

import SwiftUI


struct Cardify: ViewModifier, Animatable {
  init(selectionStatus: Card.SelectionStatus, isFaceUp: Bool) {
    self.selectionStatus = selectionStatus
    rotation = isFaceUp ? 0 : 180
  }
  
	init(selectionStatus: Card.SelectionStatus, rotation: Double) {
		self.selectionStatus = selectionStatus
		self.rotation = rotation
	}
	
  var selectionStatus: Card.SelectionStatus
  var rotation: Double
  var animatableData: Double {
    get { rotation }
    set { rotation = newValue }
  }
  
	func body(content: Content) -> some View {
		ZStack(alignment: .center) {
			let roundedRectangle = RoundedRectangle(cornerRadius: Constants.cornerRadius)
			if rotation > 90 && rotation < 270 {
				roundedRectangle
					.foregroundColor(.purple)
			} else {
				roundedRectangle
					.foregroundColor(.white)
				roundedRectangle
					.strokeBorder(lineWidth: 2)
					.highlight(selectionStatus: selectionStatus)
					.clipShape(roundedRectangle)
				content
					.padding()
			}
		}
		.rotation3DEffect(Angle(degrees: rotation), axis: (0, 1, 0))
	}
  
  private struct Constants {
    static let cornerRadius: CGFloat = 15
    static let sizeMultiplier: CGFloat = 0.8
    static let aspectRation: CGFloat = 2.7
  }
}


extension View {
  func cardify(selectionStatus: Card.SelectionStatus, isFaceUp: Bool) -> some View {
    self.modifier(Cardify(selectionStatus: selectionStatus, isFaceUp: isFaceUp))
  }
	
	func cardify(selectionStatus: Card.SelectionStatus, rotation: Double) -> some View {
		self.modifier(Cardify(selectionStatus: selectionStatus, rotation: rotation))
	}
}


struct CardContent: View {
  let card: Card
  
  var body: some View {
    let color = SetGameViewModel.uiColor(for: card.color)
    
    // If use ForEach without `id` parameter, it draw random number of shapes each time when card redraws.
    // With this hack number of shapes is constant for each particular card.
    VStack(alignment: .center) {
      ForEach(0..<card.numberOfShapes, id: \.self) { _ in
        SetGameViewModel.uiShape(for: card.shape, using: card.shapeStyle)
          .aspectRatio(Constants.aspectRation, contentMode: .fit)
          .foregroundColor(color)
      }
    }
  }
  
  private struct Constants {
    static let cornerRadius: CGFloat = 15
    static let sizeMultiplier: CGFloat = 0.8
    static let aspectRation: CGFloat = 2.7
  }
}

struct CardView_Previews: PreviewProvider {
  static let game = SetGameViewModel()
  static var previews: some View {
    let card = game.cardsInDeck.first!
    CardContent(card: card)
      .cardify(selectionStatus: card.selectionStatus, isFaceUp: true)
  }
}



///V
//struct CardView: View, Animatable {
//  init(card: Card, isFaceUp: Bool) {
//    self.card = card
//    rotation = isFaceUp ? 0 : 180
//  }
//
//  let card: Card
//  var rotation: Double
//  var animatableData: Double {
//    get { rotation }
//    set { rotation = newValue }
//  }
//  var body: some View {
//      ZStack(alignment: .center) {
//        let roundedRectangle = RoundedRectangle(cornerRadius: Constants.cornerRadius)
//        if rotation > 90 {
//          roundedRectangle
//            .foregroundColor(.purple)
//        } else {
//          roundedRectangle
//            .foregroundColor(.white)
//          roundedRectangle
//            .strokeBorder(lineWidth: 2)
//            .highlight(selectionStatus: card.selectionStatus)
//            .clipShape(roundedRectangle)
//          content(of: card)
//            .padding()
//        }
//      }
//      .rotation3DEffect(Angle(degrees: rotation), axis: (0, 1, 0))
//
//  }
//
//  /// Make a content view for a particular card using it's parameters
//  @ViewBuilder
//  func content(of card: Card) -> some View {
//    let color = SetGameViewModel.uiColor(for: card.color)
//
//    // If use ForEach without `id` parameter, it draw random number of shapes each time when card redraws.
//    // With this hack number of shapes is constant for each particular card.
//    VStack(alignment: .center) {
//      ForEach(0..<card.numberOfShapes, id: \.self) { _ in
//        SetGameViewModel.uiShape(for: card.shape, using: card.shapeStyle)
//          .aspectRatio(Constants.aspectRation, contentMode: .fit)
//          .foregroundColor(color)
//      }
//    }
//  }
//
//  private struct Constants {
//    static let cornerRadius: CGFloat = 15
//    static let sizeMultiplier: CGFloat = 0.8
//    static let aspectRation: CGFloat = 2.7
//  }
//}
