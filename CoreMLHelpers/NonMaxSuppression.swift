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

public typealias NMSPrediction = (classIndex: Int, score: Float, rect: CGRect)

/**
  Removes bounding boxes that overlap too much with other boxes that have
  a higher score.

  Based on code from https://github.com/tensorflow/tensorflow/blob/master/tensorflow/core/kernels/non_max_suppression_op.cc

  - Note: This version of NMS ignores the class of the bounding boxes.

  - Parameters:
    - predictions: an array of bounding boxes and their scores
    - limit: the maximum number of boxes that will be selected
    - threshold: used to decide whether boxes overlap too much

  - Returns: the array indices of the selected bounding boxes
*/
public func nonMaxSuppression(predictions: [NMSPrediction], limit: Int, threshold: Float) -> [Int] {

  // Sort the boxes based on their confidence scores, from high to low.
  let sortedIndices = predictions.indices.sorted { predictions[$0].score > predictions[$1].score }

  var selected: [Int] = []

  // Loop through the bounding boxes, from highest score to lowest score,
  // and determine whether or not to keep each box.
  for i in 0..<predictions.count {
    if selected.count >= limit { break }

    var shouldSelect = true
    let boxA = predictions[sortedIndices[i]]

    // Does the current box overlap one of the selected boxes more than the
    // given threshold amount? Then it's too similar, so don't keep it.
    for j in 0..<selected.count {
      let boxB = predictions[selected[j]]
      if IOU(boxA.rect, boxB.rect) > threshold {
        shouldSelect = false
        break
      }
    }

    // This bounding box did not overlap too much with any selected box, and
    // therefore we'll keep it.
    if shouldSelect {
      selected.append(sortedIndices[i])
    }
  }

  return selected
}
