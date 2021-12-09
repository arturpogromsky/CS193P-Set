//
//  Game.swift
//  Set
//
//  Created by Артур Погромский on 24.11.2021.
//

import Foundation


struct SetGame {
  
  /// Deck of 81 cards
  var deck = Deck()
  
  var scoreTracker = ScoreTracker()
  
  // MARK: - Gameplay functions
  /// Choose card, check whether chosen cards form a set or not and highlight them with apropriate color.
	/// If cards already highlighted - replace matched or disselect mismatched cards.
  mutating func chooseCard(at index: Int) {
		// First, mark card as selected or disselect, if card already was selected.
    deck[index].selectionStatus.toggle()
    
		// If there are mismatched cards, then mark them as .none and select chosen card
    let mismatchedCardsIndices = deck.mismatchedCardsIndices
    if mismatchedCardsIndices.count == 3 {
      markCards(at: mismatchedCardsIndices, as: .none)
      if mismatchedCardsIndices.contains(index) {
        deck[index].selectionStatus.toggle()
      }
      return
    }
    
		// If there are matched cards, then remove them and return from function.
    let matchedCardsIndices = deck.matchedCardsIndices
    if matchedCardsIndices.count == 3 {
      removeCards(at: matchedCardsIndices)
      return
    }
    
		// Check if selected cards form a set or not, mark them accordingly.
    let selectedCardsIndices = deck.selectedCardsIndices
    if selectedCardsIndices.count == 3 {
      if isSet(selectedCardsIndices) {
        markCards(at: selectedCardsIndices, as: .match)
        scoreTracker.updateScore()
      } else {
        markCards(at: selectedCardsIndices, as: .mismatch)
        scoreTracker.penalize()
      }
    } else if selectedCardsIndices.count > 3 {
      markCards(at: selectedCardsIndices, as: .none)
      deck[index].selectionStatus.toggle()
    }
  }
  
  mutating func startNewGame() {
    self = SetGame()
  }
  
	/// Find a cards, that forms a set and mark them as matched
  mutating func cheat() {
    removeMatchedCards()
    markCards(at: deck.selectedCardsIndices, as: .none)
    if let setIndices = findSet() {
      markCards(at: setIndices, as: .match)
      scoreTracker.updateScore()
    }
  }
  
  /// Add 12 cards from deck on table
  mutating func deal() {
    removeMatchedCards()
    if deck.numberOfCardsToDisplay < deck.allCards.count {
      deck.numberOfCardsToDisplay += 1
    }
  }
  
  // MARK: - Private
  /// Takes 3 cards as input and checks if they form a set.
  private func isSet(_ cardIndices: [Int]) -> Bool {
    let shapesCount = Set<Card.Shape>(cardIndices.map { deck[$0].shape }).count
    let shapeStylesCount = Set<Card.ShapeStyle>(cardIndices.map { deck[$0].shapeStyle }).count
    let colorsCount = Set<Card.Color>(cardIndices.map { deck[$0].color }).count
    let numbersCount = Set<Int>(cardIndices.map { deck[$0].numberOfShapes }).count
    if shapesCount == 2 || shapeStylesCount == 2 || colorsCount == 2 || numbersCount == 2 {
      return false
    }
    return true
  }
  
	/// Find matched cards and remove them
  private mutating func removeMatchedCards() {
    let matchedCardsIndices = deck.allCards.indices.filter { deck.allCards[$0].selectionStatus == .match }
    if matchedCardsIndices.count == 3 {
      removeCards(at: matchedCardsIndices)
    }
  }
  
	/// Change `selectionStatus` of given cards to `newSelectionStatus`
  private mutating func markCards(at indices: [Int], as newSelectionStatus: Card.SelectionStatus) {
    for index in indices {
      deck.allCards[index].selectionStatus = newSelectionStatus
    }
  }
  
  /// Delete cards from deck and add to discard pile
  private mutating func removeCards(at indices: [Int]) {
    
    // Search id for each of cards
    let ids = indices.map { deck[$0].id }
    
    // Then remove cards with such id from deck.allCards and add to deck.discardPile
    for id in ids {
      let indexForId = deck.allCards.firstIndex(where: { $0.id == id })!
      deck[indexForId].selectionStatus = .none
      deck.discardPile.append(deck.allCards.remove(at: indexForId))
    }
    
    if deck.numberOfCardsToDisplay > 12 {
      deck.numberOfCardsToDisplay -= 3
    }
  }
  
	/// If `cardsToDisplay` contains a set, then return indices of cards that forms it. If not, return `nil`
  private func findSet() -> [Int]? {
    let cardsToDisplay = deck.cardsToDisplay
    for first in cardsToDisplay.indices {
      for second in cardsToDisplay.indices {
        for third in cardsToDisplay.indices {
          if deck[first].id == deck[second].id ||
              deck[second].id == deck[third].id ||
              deck[first].id == deck[third].id
          {
            continue
          }
          if isSet([first, second, third]) {
            return [first, second, third]
          }
        }
      }
    }
    return nil
  }

}

struct Deck {
  var allCards: [Card] {
    willSet {
      if newValue.count < numberOfCardsToDisplay {
        numberOfCardsToDisplay = newValue.count
      }
    }
  }
  
  /// Number of cards to show on screen.
  var numberOfCardsToDisplay = 0
  
  var cardsToDisplay: [Card] {
    Array(allCards[..<numberOfCardsToDisplay])
  }
  
  var cardsInDeck: [Card] {
    Array(allCards[numberOfCardsToDisplay...])
  }
  
  /// Array which contains matched(and deleted from deck) cards
  var discardPile: [Card] = []
  
  var selectedCardsIndices: [Int] {
    allCards.indices.filter { allCards[$0].selectionStatus != .none }
  }
  var matchedCardsIndices: [Int] {
    allCards.indices.filter { allCards[$0].selectionStatus == .match }
  }
  var mismatchedCardsIndices: [Int] {
    allCards.indices.filter { allCards[$0].selectionStatus == .mismatch }
  }
  
  /// Create a deck of cards, each with 1 of 3 shape, color, shapeStyle and numberOfShapes, 81 cards in total
  init() {
    allCards = []
    for shape in Card.Shape.allCases {
      for color in Card.Color.allCases {
        for shapeStyle in Card.ShapeStyle.allCases {
          for numberOfShapes in 1...3 {
            allCards.append(Card(shape: shape,
                              color: color,
                              shapeStyle: shapeStyle,
                              numberOfShapes: numberOfShapes))
          }
        }
      }
    }
    allCards.shuffle()
  }
  
  subscript(index: Int) -> Card {
    get {
      allCards[index]
    }
    set {
      allCards[index] = newValue
    }
  }
}


/// Model for specific card
struct Card: Identifiable, Equatable {
  let shape: Shape
  let color: Color
  let shapeStyle: ShapeStyle
  let numberOfShapes: Int
  let id = UUID()
  var selectionStatus: SelectionStatus = .none
  
  enum Shape: CaseIterable, Hashable {
    case diamond, squiggle, oval
  }
  
  enum Color: CaseIterable, Hashable {
    case red, green, purple
  }
  
  enum ShapeStyle: CaseIterable, Hashable {
    case opaque, stripped, transparent
  }
  
  enum SelectionStatus {
    case none, selected, mismatch, match
    mutating func toggle() {
      switch self {
      case .none:
        self = .selected
      case .selected:
        self = .none
      case .mismatch, .match:
        break
      }
    }
  }
}

struct ScoreTracker {
  var score = 0
  var latestUpdate = Date()
  
  mutating func updateScore() {
    let currentDate = Date()
    let timeSinceLastUpdate = currentDate.timeIntervalSince(latestUpdate)
    score += 30 + abs(Int(30.0 - timeSinceLastUpdate))
    latestUpdate = currentDate
  }
  
  mutating func penalize() {
    score -= 30
  }
}
