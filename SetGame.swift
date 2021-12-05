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
  
  /// Choose card, check whether chosen cards form a set or not and highlight them with apropriate color. If cards already highlighted - replace matched or disselect mismatched cards.
  mutating func chooseCard(at index: Int) {
    deck[index].selectionStatus.toggle()
    
    let mismatchedCardsIndices = deck.mismatchedCardsIndices
    if mismatchedCardsIndices.count == 3 {
      markCards(at: mismatchedCardsIndices, as: .none)
      if mismatchedCardsIndices.contains(index) {
        deck[index].selectionStatus.toggle()
      }
      return
    }
    
    let matchedCardsIndices = deck.matchedCardsIndices
    if matchedCardsIndices.count == 3 {
      removeCards(at: matchedCardsIndices)
      return
    }
    
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
  
  /// Add 3 cards to cards on screen
  mutating func addCards() {
    if deck.numberOfCardsToDisplay <= deck.allCards.count - 3 {
      deck.numberOfCardsToDisplay += 3
    }
    replaceMatchedCards()
  }
  
  mutating func startNewGame() {
    self = SetGame()
  }
  
  mutating func cheat() {
    replaceMatchedCards()
    markCards(at: deck.selectedCardsIndices, as: .none)
    if let setIndices = findSet() {
      markCards(at: setIndices, as: .match)
      scoreTracker.updateScore()
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
  
  private mutating func replaceMatchedCards() {
    let matchedCardsIndices = deck.allCards.indices.filter { deck.allCards[$0].selectionStatus == .match }
    if matchedCardsIndices.count == 3 {
      removeCards(at: matchedCardsIndices)
      return
    }
  }
  
  private mutating func markCards(at indices: [Int], as selectionStatus: Card.SelectionStatus) {
    for index in indices {
      deck.allCards[index].selectionStatus = selectionStatus
    }
  }
  
  private mutating func removeCards(at indices: [Int]) {
    let ids = indices.map { deck[$0].id }
    for id in ids {
      deck.allCards.remove(at: deck.allCards.firstIndex(where: { $0.id == id })!)
    }
    if deck.numberOfCardsToDisplay > 12 {
      deck.numberOfCardsToDisplay -= 3
    }
  }
  
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
  var numberOfCardsToDisplay = 12
  
  var cardsToDisplay: [Card] {
    Array(allCards[..<numberOfCardsToDisplay])
  }
  
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

///Version of `chooseCard` that automatically deletes cards that form a set.
//mutating func chooseCard(at index: Int) {
//  cards[index].selectionStatus.toggle()
//  let selectedCardsIndices = cards.indices.filter { cards[$0].selectionStatus != .none }
//  if selectedCardsIndices.count == 3 {
//    if isSet(selectedCardsIndices) {
//      var offset = 0
//      for selectedCardsIndex in selectedCardsIndices {
//        cards.remove(at: selectedCardsIndex - offset)
//        offset += 1
//      }
//      if numberOfCardsToDisplay > 12 {
//        numberOfCardsToDisplay -= 3
//      }
//    } else {
//      for selectedCardsIndex in selectedCardsIndices {
//        cards[selectedCardsIndex].selectionStatus = .mismatch
//      }
//    }
//  } else if selectedCardsIndices.count > 3 {
//    for selectedCardsIndex in selectedCardsIndices {
//      cards[selectedCardsIndex].selectionStatus = .none
//    }
//    cards[index].selectionStatus.toggle()
//  }
//}
