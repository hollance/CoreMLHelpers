import UIKit
import CoreML
import CoreMLHelpers

class MenuViewController: UITableViewController {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier! {
    case "PixelBuffer2RGB":
      (segue.destination as! ImageViewController).image = pixelBuffer2RGB()
    case "PixelBuffer2Grayscale":
      (segue.destination as! ImageViewController).image = pixelBuffer2Grayscale()
    case "MultiArray2RGB":
      (segue.destination as! ImageViewController).image = multiArray2RGB()
    case "MultiArray2Grayscale":
      (segue.destination as! ImageViewController).image = multiArray2Grayscale()
    case "NMS":
      (segue.destination as! NMSViewController).multiClass = false
    case "NMSMulti":
      (segue.destination as! NMSViewController).multiClass = true
    default:
      break
    }
  }

  // MARK: - Test CVPixelBuffer to RGB image

  func pixelBuffer2RGB() -> UIImage? {
    let image = UIImage(named: "cat.jpg")!

    // Convert image to CVPixelBuffer.
    if let pixelBuffer = image.pixelBuffer(width: 150, height: 150) {

      // Test resizing of pixel buffer.
      if let resizedPixelBuffer = resizePixelBuffer(pixelBuffer, width: 200, height: 300) {

        // Convert back to image.
        if let image = UIImage(pixelBuffer: resizedPixelBuffer) {
          return image
        }
      }
    }
    return nil
  }

  // MARK: - Test CVPixelBuffer to grayscale image

  let ciContext = CIContext()
  var resizedPixelBuffer: CVPixelBuffer?

  func pixelBuffer2Grayscale() -> UIImage? {
    let image = UIImage(named: "cat.jpg")!

    // Allocate this pixel buffer just once and keep reusing it.
    resizedPixelBuffer = createPixelBuffer(width: 200, height: 300)

    // Convert image to a grayscale CVPixelBuffer.
    if let pixelBuffer = image.pixelBufferGray(width: 150, height: 150) {

      // Test resizing of pixel buffer using Core Image.
      if let resizedPixelBuffer = resizedPixelBuffer {
        resizePixelBuffer(pixelBuffer, width: 200, height: 300,
                          output: resizedPixelBuffer, context: ciContext)

        // Convert back using Core Image.
        if let image = UIImage(pixelBuffer: resizedPixelBuffer, context: ciContext) {
          return image
        }
      }
    }
    return nil
  }

  // MARK: - Test MLMultiArray to RGB image

  func loadCat() -> MLMultiArray? {
    // cat.bin contains cat.jpg saved as doubles in the range [0,1) with shape
    // (3, 360, 480). Load this binary data into a new MLMultiArray object.
    let url = Bundle.main.url(forResource: "cat", withExtension: "bin")!
    let data = try! Data(contentsOf: url)
    let ptr = UnsafeMutableRawPointer(mutating: (data as NSData).bytes)
    return try? MLMultiArray(dataPointer: ptr,
                             shape: [3, 360, 480],
                             dataType: .double,
                             strides: [NSNumber(value: 360*480), 480, 1])
  }

  func multiArray2RGB() -> UIImage? {
    if let coreMLArray = loadCat() {
      // Use CoreMLHelpers' MultiArray. The advantage of this method is that
      // you can use reshaped() and/or transposed() if necessary.
      //let myArray = MultiArray<Double>(coreMLArray)
      //return myArray.image(offset: 0, scale: 255)

      // Directly use the MLMultiArray:
      return coreMLArray.image(offset: 0, scale: 255)
    }
    return nil
  }

  func multiArray2Grayscale() -> UIImage? {
    if let coreMLArray = loadCat() {
      // Just for testing purposes, re-interpret the cat image (which is RGB)
      // as grayscale. This creates an image that is 3 times as tall, with the
      // red channel on top of the green channel, on top of the blue channel.
      //return MultiArray<Double>(coreMLArray).reshaped([3*360, 480])
      //                                      .image(offset: 0, scale: 255)

      // Only show the blue channel:
      return MultiArray<Double>(coreMLArray).image(channel: 2, offset: 0, scale: 255)
    }
    return nil
  }
}
