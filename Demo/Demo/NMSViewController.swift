import UIKit
import CoreMLHelpers

class NMSViewController: UIViewController {
  let numBoxes = 80
  let numClasses = 4
  let selectHowMany = 6
  let selectPerClass = 2
  let scoreThreshold: Float = 0.1
  let iouThreshold: Float = 0.5

  var boundingBoxes: [BoundingBox] = []
  var multiClass = false

  override func viewDidLoad() {
    super.viewDidLoad()

    // Create shape layers for the bounding boxes.
    for _ in 0..<numBoxes {
      let box = BoundingBox()
      box.addToLayer(view.layer)
      boundingBoxes.append(box)
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    refresh()
  }

  @IBAction func refresh() {
    // Create a random color for each class. The "inactive" color shows the
    // boxes that were not selected.
    var activeColors: [UIColor] = []
    var inactiveColors: [UIColor] = []
    for _ in 0..<numClasses {
      let r = random()
      let g = random()
      let b = random()
      activeColors.append(UIColor(red: r, green: g, blue: b, alpha: 1))
      inactiveColors.append(UIColor(red: r, green: g, blue: b, alpha: 0.1))
    }

    // To get a somewhat realistic test, put all the bounding boxes for a
    // given class close to one another.
    let width = view.bounds.width
    let height = view.bounds.height - 44
    let clusterX1 = width / 4
    let clusterX2 = 3 * clusterX1
    let clusterY1 = height / 4
    let clusterY2 = 3 * clusterY1

    var clusterXs: [CGFloat] = []
    var clusterYs: [CGFloat] = []
    clusterXs.append(clusterX1)
    clusterYs.append(clusterY1)
    clusterXs.append(clusterX2)
    clusterYs.append(clusterY1)
    clusterXs.append(clusterX1)
    clusterYs.append(clusterY2)
    clusterXs.append(clusterX2)
    clusterYs.append(clusterY2)

    // Create random predictions around the clusters.
    var predictions: [NMSPrediction] = []
    for _ in 0..<numBoxes {
      let classIndex = random(numClasses)
      let clusterX = clusterXs[classIndex]
      let clusterY = clusterYs[classIndex]

      let x1 = max(0, clusterX - random() * width/4)
      let x2 = min(width, clusterX + random() * width/4)
      let y1 = max(0, clusterY - random() * height/4)
      let y2 = min(height, clusterY + random() * height/4)

      let rect = CGRect(x: x1, y: 44 + y1, width: x2 - x1, height: y2 - y1)
      let score = Float(random())
      predictions.append((classIndex, score, rect))
    }

    // Perform non-maximum suppression to find the best bounding boxes.
    let selected: [Int]
    if multiClass {
      selected = nonMaxSuppressionMultiClass(numClasses: numClasses,
                                             predictions: predictions,
                                             scoreThreshold: scoreThreshold,
                                             iouThreshold: iouThreshold,
                                             maxPerClass: selectPerClass,
                                             maxTotal: selectHowMany)
    } else {
      // First remove bounding boxes whose score is too low.
      let filteredIndices = predictions.indices.filter { predictions[$0].score > scoreThreshold }

      selected = nonMaxSuppression(predictions: predictions,
                                   indices: filteredIndices,
                                   iouThreshold: iouThreshold,
                                   maxBoxes: selectHowMany)
    }

    // Show the bounding boxes, with the selected boxes in full color.
    for i in 0..<numBoxes {
      let prediction = predictions[i]
      let color: UIColor
      let textColor: UIColor
      if selected.contains(i) {
        color = activeColors[prediction.classIndex]
        textColor = UIColor.black
      } else {
        color = inactiveColors[prediction.classIndex]
        textColor = UIColor(white: 0, alpha: 0.2)
      }
      boundingBoxes[i].show(frame: prediction.rect,
                            label: String(format: "%.2f", prediction.score),
                            color: color, textColor: textColor)
    }
  }

  func random() -> CGFloat {
    return CGFloat(arc4random())/0xffffffff
  }

  func random(_ x: Int) -> Int {
    return Int(arc4random_uniform(UInt32(x)))
  }
}
