import UIKit
import Vision
import CoreML

class ViewController: UIViewController {

  @IBOutlet weak var imageView: UIImageView!

  let ciContext = CIContext()
  var resizedPixelBuffer: CVPixelBuffer?

  override func viewDidLoad() {
    super.viewDidLoad()

    testImagePixelBufferConversion()
    testImagePixelBufferConversionGray()
    testMultiArrayFromCoreMLArray()
    testMultiArray()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func testImagePixelBufferConversion() {
    let image = UIImage(named: "cat.jpg")!

    // Convert image to CVPixelBuffer.
    if let pixelBuffer = image.pixelBuffer(width: 150, height: 150) {

      // Test resizing of pixel buffer.
      if let resizedPixelBuffer = resizePixelBuffer(pixelBuffer, width: 200, height: 300) {

        // Convert back to image.
        if let image = UIImage(pixelBuffer: resizedPixelBuffer) {
          imageView.image = image
        }
      }
    }
  }

  func testImagePixelBufferConversionGray() {
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
          imageView.image = image
        }
      }
    }
  }

  func testMultiArrayFromCoreMLArray() {
    let coreMLArray = try! MLMultiArray(shape: [3, 4, 2], dataType: .double)
    coreMLArray[[1, 2, 0] as [NSNumber]] = NSNumber(value: 3.14159)
    print(coreMLArray)

    var m = MultiArray<Double>(coreMLArray)
    print(m.shape)
    print(m[1, 2, 0])

    m[1, 2, 0] = 2.71828
    print(m[[1, 2, 0]])
  }

  func testMultiArray() {
    var m = MultiArray<Float>(shape: [3, 4, 2])
    print(m.shape)

    for i in 0..<m.count {
      m[i] = Float(i)
    }
    print(m)

    let t = m.transposed([1, 2, 0])
    print(t.shape)
    print(t)

    let r = m.reshaped([8, 3])
    print(r.shape)
    print(r)
  }
}
