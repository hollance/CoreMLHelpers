/*
  Copyright (c) 2017 M.I. Hollemans

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

import Foundation
import UIKit
import CoreML
import Accelerate

/**
  Computes intersection-over-union overlap between two bounding boxes.
*/
public func IOU(_ a: CGRect, _ b: CGRect) -> Float {
  let areaA = a.width * a.height
  if areaA <= 0 { return 0 }

  let areaB = b.width * b.height
  if areaB <= 0 { return 0 }

  let intersectionMinX = max(a.minX, b.minX)
  let intersectionMinY = max(a.minY, b.minY)
  let intersectionMaxX = min(a.maxX, b.maxX)
  let intersectionMaxY = min(a.maxY, b.maxY)
  let intersectionArea = max(intersectionMaxY - intersectionMinY, 0) *
                         max(intersectionMaxX - intersectionMinX, 0)
  return Float(intersectionArea / (areaA + areaB - intersectionArea))
}

//TODO: more to come here!
