import UIKit
import Vision
import CoreML
import CoreMLHelpers

class ImageViewController: UIViewController {

  @IBOutlet weak var imageView: UIImageView!

  var image: UIImage?

  override func viewDidLoad() {
    super.viewDidLoad()
    imageView.image = image
  }
}
