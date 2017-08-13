import Foundation
import UIKit

class BoundingBox {
  let shapeLayer: CAShapeLayer
  let textLayer: CATextLayer

  init() {
    shapeLayer = CAShapeLayer()
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.lineWidth = 4
    shapeLayer.isHidden = true

    textLayer = CATextLayer()
    textLayer.isHidden = true
    textLayer.contentsScale = UIScreen.main.scale
    textLayer.fontSize = 14
    textLayer.font = UIFont(name: "Avenir", size: textLayer.fontSize)
    textLayer.alignmentMode = kCAAlignmentCenter
  }

  func addToLayer(_ parent: CALayer) {
    parent.addSublayer(shapeLayer)
    parent.addSublayer(textLayer)
  }

  func show(frame: CGRect, label: String, color: UIColor, textColor: UIColor = .black) {
    CATransaction.setDisableActions(true)

    let path = UIBezierPath(rect: frame)
    shapeLayer.path = path.cgPath
    shapeLayer.strokeColor = color.cgColor
    shapeLayer.isHidden = false

    textLayer.string = label
    textLayer.foregroundColor = textColor.cgColor
    textLayer.backgroundColor = color.cgColor
    textLayer.isHidden = false

    let attributes = [
      NSAttributedStringKey.font: textLayer.font as Any
    ]

    let textRect = label.boundingRect(with: CGSize(width: 400, height: 100),
                                      options: .truncatesLastVisibleLine,
                                      attributes: attributes, context: nil)
    let textSize = CGSize(width: textRect.width + 12, height: textRect.height)
    let textOrigin = CGPoint(x: frame.origin.x - 2, y: frame.origin.y - textSize.height)
    textLayer.frame = CGRect(origin: textOrigin, size: textSize)
  }

  func hide() {
    shapeLayer.isHidden = true
    textLayer.isHidden = true
  }
}
