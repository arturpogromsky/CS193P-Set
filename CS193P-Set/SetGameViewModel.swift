//
//  GameViewModel.swift
//  Set
//
//  Created by Артур Погромский on 24.11.2021.
//

import SwiftUI


class SetGameViewModel: ObservableObject {
  
  @Published  var model = SetGame()
  
  var score: Int {
    model.scoreTracker.score
  }
  
  var cardsToDisplay: [Card] {
    model.deck.cardsToDisplay
  }
  
  var cardsInDeck: [Card] {
    model.deck.cardsInDeck
  }
  
  var discardPile: [Card] {
    model.deck.discardPile
  }
	
  // MARK: - Intent functions
	/// Find a set
  func cheat() {
    model.cheat()
  }
  
  /// Search for index of `card` and then call `model.choose(with:)` method with the index.
  func choose(_ card: Card) {
    guard let cardIndex = model.deck.allCards.firstIndex(where: { $0.id == card.id })
    else { return }
    model.chooseCard(at: cardIndex)
  }
	
	/// Recreate a model
  func startNewGame() {
    model.startNewGame()
  }
  
	/// Push 1 card from deck
  func deal() {
    model.deal()
  }
  
  //MARK: - View supply
  ///Returns `SwiftUI.Color` for `Card.Color` enum instance.
  static func uiColor(for cardColor: Card.Color) -> Color {
    switch cardColor {
    case .red: return .red
    case .green: return .green
    case .purple: return .purple
    }
  }
  
  /// Takes Card's Shape and ShapeStyle enums instances and returns actual Shape with custom `.shapeModifier` applied to it.
  @ViewBuilder
  static func uiShape(for cardShape: Card.Shape, using shapeStyle: Card.ShapeStyle) -> some View {
    switch cardShape {
    case .diamond: Diamond().shapeModifier(shapeStyle: shapeStyle)
    case .squiggle: Squiggle().shapeModifier(shapeStyle: shapeStyle)
    case .oval: Capsule().shapeModifier(shapeStyle: shapeStyle)
    }
  }
}

extension View where Self: Shape {
  
  /// Adds `.fill()`, `.stroke(lineWidth:)` or `.stripped()` modifier, depending on `shapeStyle` value.
  @ViewBuilder
  func shapeModifier(shapeStyle: Card.ShapeStyle) -> some View {
    switch shapeStyle {
    case .opaque: self.fill()
    case .transparent: self.stroke(lineWidth: 2)
    case .stripped: self.stripped()
    }
  }
}


extension View {
  
  ///Highlights card depending on it's `selectionStatus` property. For .selected adds purple glow, for .mismatch adds red glow
  @ViewBuilder 
  func highlight(selectionStatus: Card.SelectionStatus) -> some View {
    switch selectionStatus {
    case .none: self
    case .selected:
      self
        .shadow(color: .purple, radius: 5)
        .shadow(color: .purple, radius: 5)
        .shadow(color: .purple, radius: 5)
    case .mismatch:
      self
        .shadow(color: .red, radius: 5)
        .shadow(color: .red, radius: 5)
        .shadow(color: .red, radius: 5)
    case .match:
      self
        .shadow(color: .green, radius: 5)
        .shadow(color: .green, radius: 5)
        .shadow(color: .green, radius: 5)
    }
  }
}
