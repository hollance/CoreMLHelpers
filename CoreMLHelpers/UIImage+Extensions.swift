/*
  Copyright (c) 2017-2019 M.I. Hollemans

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to
  deal in the Software without restriction, including without limitation the
  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
  sell copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
  IN THE SOFTWARE.
*/

#if canImport(UIKit)

import UIKit

extension UIImage {
  /**
    Resizes the image.

    - Parameters:
      - scale: If this is 1, `newSize` is the size in pixels.
  */
  @nonobjc public func resized(to newSize: CGSize, scale: CGFloat = 1) -> UIImage {
    let format = UIGraphicsImageRendererFormat.default()
    format.scale = scale
    let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
    let image = renderer.image { _ in
      draw(in: CGRect(origin: .zero, size: newSize))
    }
    return image
  }
  /**
    Rotates the image.

    - Parameters:
      - degrees: Rotation angle in degrees.
  */
  @nonobjc public func rotate(degrees: CGFloat) -> UIImage {
      let radians = CGFloat(degrees * .pi) / 180.0 as CGFloat
      var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: radians)).size
      // Trim off the extremely small float value to prevent core graphics from rounding it up
      newSize.width = floor(newSize.width)
      newSize.height = floor(newSize.height)
      let renderer = UIGraphicsImageRenderer(size:newSize)
      let image = renderer.image { rendererContext in
          let context = rendererContext.cgContext
          //rotate from center
          context.translateBy(x: newSize.width/2, y: newSize.height/2)
          context.rotate(by: radians)
          draw(in:  CGRect(origin: CGPoint(x: -self.size.width/2, y: -self.size.height/2), size: size))
      }
      return image
  }

}

#endif
