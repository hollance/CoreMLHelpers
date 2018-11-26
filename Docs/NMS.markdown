# Non-maximum suppression (NMS)

For [object detection models](https://github.com/hollance/YOLO-CoreML-MPSNNGraph), you'll often end up with many bounding box predictions (hundreds or thousands) but not all of these are useful. *Non-maximum suppression* is used to only keep the best bounding boxes.

![NMS](NMS.png)

Each bounding box prediction consists of a rectangle, the predicted class for the object inside the rectangle, and a confidence score.

```swift
public struct BoundingBox {
  public let classIndex: Int
  public let score: Float
  public let rect: CGRect
}
```

To perform NMS, put your bounding boxes into an array of `BoundingBox` objects and call `nonMaxSuppression()`:

```swift
var predictions: [BoundingBox] = ...

let selected = nonMaxSuppression(boundingBoxes: predictions, iouThreshold: 0.5, maxBoxes: 10)
```

This gives you an array with the indices of the best bounding boxes.

Tip: If you have many bounding boxes, you first want to remove predictions with low scores before calling NMS. This will save on processing time.

```swift
let filteredIndices = predictions.indices.filter { predictions[$0].score > scoreThreshold }

let selected = nonMaxSuppression(boundingBoxes: predictions,
                                 indices: filteredIndices,
                                 iouThreshold: 0.5,
                                 maxBoxes: 10)
```
 
There is also a multi-class version of NMS. The difference is that the multi-class version first tries to find the best bounding boxes for each class, and then makes its final selection from those (whereas "regular" NMS does not care about the class of the bounding boxes at all). With the multi-class method you can usually expect to see at least one bounding box for each class (unless all the bounding boxes for a class score really badly).

```swift
let selected = nonMaxSuppressionMultiClass(numClasses: ...,
                                           boundingBoxes: predictions,
                                           scoreThreshold: 0.01,
                                           iouThreshold: 0.5,
                                           maxPerClass: ...,
                                           maxTotal: ...)
```

Multi-class NMS is slower than the class-independent version since it needs to look at each class individually. Tuning the thresholds and the `maxPerClass` and `maxTotal` values is essential for getting good accuracy and speed.
