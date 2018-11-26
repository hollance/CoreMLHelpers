# Images and CVPixelBuffers

If your model takes an image as input, Core ML expects it to be in the form of a `CVPixelBuffer` (also known as `CVImageBuffer`). The pixel buffer must also have the correct width and height. 

So if you've got a `UIImage`, `CGImage`, `CIImage`, or `CMSampleBuffer` (or something else), you first have to convert -- and resize -- the image before Core ML can use it.

### Tip: use Vision

When working with images, it's a good idea to use the Vision framework to drive Core ML. Vision will automatically convert your image to the format and size that the Core ML model expects. 

First, you create a `VNCoreMLRequest` object. This is where you provide the completion handler that gets called when Vision and Core ML have made a prediction. You do this just once and keep track of this `VNCoreMLRequest` instance in a property.

```swift
// Add this as a property:
var request: VNCoreMLRequest?

// Do this just once:
if let visionModel = try? VNCoreMLModel(for: yourCoreMLModel.model) {
  request = VNCoreMLRequest(model: visionModel) { request, error in
    if let observations = request.results as? [VNClassificationObservation] {
      print(observations)
    }
  }
}

// Specify additional options:
request.imageCropAndScaleOption = .centerCrop
request.regionOfInterest = ...
```

To make a prediction, you create a `VNImageRequestHandler` using a `CGImage`, `CIImage`, or `CVPixelBuffer` and run it:

```swift
let handler = VNImageRequestHandler(cgImage: ...)
try? handler.perform([request])
```

### When not using Vision

In the case where you can't or don't want to use Vision, you'll need to convert your images to `CVPixelBuffer` objects by hand. CoreMLHelpers has a few useful methods to help with this.

To convert and resize a `UIImage` (or `CGImage`):

```swift
let image = UIImage(...)

// Convert the image
if let pixelBuffer = image.pixelBuffer(width: 224, height: 224) {

  // Make the prediction with Core ML
  if let prediction = try? model.prediction(input: pixelBuffer) {
    print(prediction)
  }
}
```

To get a grayscale pixel buffer, use `image.pixelBufferGray(...)`.

When you're using AVFoundation to read video frames from the camera, this will give `CMSampleBuffer` objects. You can convert these to a `CVPixelBuffer` using:

```swift
let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
```

This pixel buffer will have the width and height of the camera, which are likely too big for your model. To resize the pixel buffer you can use a CoreMLHelpers function:

```swift
if let resizedPixelBuffer = resizePixelBuffer(pixelBuffer, width: 200, height: 300) {
  // use resizedPixelBuffer
}
```

As an alternative, you can use a version that uses Core Image to do the resizing. You'll need to create a `CIContext` and `CVPixelBuffer` just once and then reuse them.

```swift
// Declare these as properties:
let ciContext = CIContext()
var resizedPixelBuffer: CVPixelBuffer?

// Allocate this pixel buffer just once and keep reusing it:
resizedPixelBuffer = createPixelBuffer(width: 200, height: 300)

// To resize your CVPixelBuffer:
if let resizedPixelBuffer = resizedPixelBuffer {
  resizePixelBuffer(pixelBuffer, width: 200, height: 300, 
                    output: resizedPixelBuffer, context: ciContext)

  // use resizedPixelBuffer
}
```

To convert the `CVPixelBuffer` back to a `UIImage` (useful for debugging), do:

```swift
if let image = UIImage(pixelBuffer: resizedPixelBuffer) {
  // do something with image
}
```

or using Core Image:

```swift
if let image = UIImage(pixelBuffer: resizedPixelBuffer, context: ciContext) {
  // do something with image
}
```
