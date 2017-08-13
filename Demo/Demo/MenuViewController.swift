import UIKit

class MenuViewController: UITableViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier! {
    case "ShowRGB":
      (segue.destination as! ImageViewController).rgb = true
    case "ShowGrayscale":
      (segue.destination as! ImageViewController).rgb = false
    case "NMS":
      (segue.destination as! NMSViewController).multiClass = false
    case "NMSMulti":
      (segue.destination as! NMSViewController).multiClass = true
    default:
      break
    }
  }
}
