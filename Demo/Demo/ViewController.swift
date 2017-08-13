import UIKit
import Vision
import CoreML
import CoreMLHelpers

class ViewController: UIViewController {

  @IBOutlet weak var imageView: UIImageView!

  let ciContext = CIContext()
  var resizedPixelBuffer: CVPixelBuffer?

  override func viewDidLoad() {
    super.viewDidLoad()

    testImagePixelBufferConversion()
    testImagePixelBufferConversionGray()
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
}
