//
//  CardView.swift
//  Set
//
//  Created by Артур Погромский on 26.11.2021.
//

import SwiftUI

///V
struct CardView: View, Identifiable {
  let viewModel: SetGameViewModel
  let card: Card
  let id = UUID()
  var body: some View {
    GeometryReader { container in
      ZStack(alignment: .center) {
        let roundedRectangle = RoundedRectangle(cornerRadius: Constants.cornerRadius)
        
        roundedRectangle
          .foregroundColor(.white)
        roundedRectangle
          .strokeBorder(lineWidth: 2)
          .highlight(selectionStatus: card.selectionStatus)
          .clipShape(roundedRectangle)
        content(of: card)
          .padding()
      }
    }
  }
  
  /// Make a content view for a particular card using it's parameters
  @ViewBuilder
  func content(of card: Card) -> some View {
    let color = viewModel.uiColor(for: card.color)
    
    // If use ForEach without `id` parameter, it draw random number of shapes each time when card redraws.
    // With this hack number of shapes is constant for each particular card.
    VStack(alignment: .center) {
      ForEach(0..<card.numberOfShapes, id: \.self) { _ in
        viewModel.uiShape(for: card.shape, using: card.shapeStyle)
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

//struct CardView_Previews: PreviewProvider {
//  static let game = SetGameViewModel()
//  static var previews: some View {
//    CardView(viewModel: game, card: game.cards.first!)
//  }
//}
