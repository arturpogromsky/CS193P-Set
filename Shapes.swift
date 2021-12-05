//
//  CardShapes.swift
//  Set
//
//  Created by Артур Погромский on 24.11.2021.
//

import SwiftUI

struct Shapes: View {
    var body: some View {
      VStack {
        Diamond()
          .stroke(Color.red)
          .frame(width: 200, height: 70)
        Squiggle()
          .fill()
          .frame(width: 200, height: 70)
          .foregroundColor(.blue)
        Squiggle()
          .stripped()
          .frame(width: 200, height: 70)
          .foregroundColor(.purple)
      }
    }
}

struct Diamond: Shape {
  func path(in rect: CGRect) -> Path {
    let leftCorner = CGPoint(x: 0, y: rect.midY)
    let rightCorner = CGPoint(x: rect.maxX, y: rect.midY)
    let topCorner = CGPoint(x: rect.midX, y: rect.minY)
    let bottomCorner = CGPoint(x: rect.midX, y: rect.maxY)
    var path = Path()
    path.move(to: topCorner)
    path.addLines([topCorner, rightCorner, bottomCorner, leftCorner, topCorner])
    return path
  }
}

struct Squiggle: Shape {
  func path(in rect: CGRect) -> Path {
    var upper =  Path()
    let sqdx = rect.width * 0.1
    let sqdy = rect.height * 0.2
    
    upper.move(to: CGPoint(x: rect.minX,y: rect.midY))
    upper.addCurve(to: CGPoint(x: rect.minX + rect.width * 1/2,
                               y: rect.minY + rect.height / 8),
                   control1: CGPoint(x: rect.minX,y: rect.minY),
                   control2: CGPoint(x: rect.minX + rect.width * 1/2 - sqdx,
                                     y: rect.minY + rect.height / 8 - sqdy))
    
    upper.addCurve(to: CGPoint(x: rect.minX + rect.width * 4/5,
                               y: rect.minY + rect.height / 8),
                   control1: CGPoint(x: rect.minX + rect.width * 1/2 + sqdx,
                                     y: rect.minY + rect.height / 8 + sqdy),
                   control2: CGPoint(x: rect.minX + rect.width * 4/5 - sqdx,
                                     y: rect.minY + rect.height / 8 + sqdy))
    
    upper.addCurve(to: CGPoint(x: rect.minX + rect.width,
                               y: rect.minY + rect.height / 2),
                   control1: CGPoint(x: rect.minX + rect.width * 4/5 + sqdx,
                                     y: rect.minY + rect.height / 8 - sqdy ),
                   control2: CGPoint(x: rect.minX + rect.width,
                                     y: rect.minY))
    
    var lower = upper
    lower = lower.applying(CGAffineTransform.identity.rotated(by: CGFloat.pi))
    lower = lower.applying(CGAffineTransform.identity
                            .translatedBy(x: rect.size.width, y: rect.size.height))
    upper.move(to: CGPoint(x: rect.minX, y: rect.midY))
    upper.addPath(lower)
    return upper
  }
}

struct Stripes: Shape {
  let step: CGFloat
  func path(in rect: CGRect) -> Path {
    var path = Path()
    var currentX = rect.minX
    path.move(to: CGPoint(x: currentX, y: rect.minY))
    while currentX <= rect.maxX {
      path.addLine(to: CGPoint(x: currentX, y: rect.maxY))
      currentX += step
      path.move(to: CGPoint(x: currentX, y: rect.minY))
    }
    return path
  }
}


extension Shape {
  func stripped(lineWidth: CGFloat = 1, step: CGFloat = 3) -> some View {
    Stripes(step: step)
      .stroke(lineWidth: lineWidth)
      .clipShape(self)
      .overlay(self.stroke(lineWidth: lineWidth))
  }
}

//struct CardShapes_Previews: PreviewProvider {
//    static var previews: some View {
//        Shapes()
//    }
//}
