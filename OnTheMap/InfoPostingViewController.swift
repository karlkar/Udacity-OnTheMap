
import UIKit
import MapKit

class InfoPostingViewController : UIViewController {
    
    @IBOutlet weak var locationText: UITextField!
    @IBOutlet weak var linkText: UITextField!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Add location"
        progressIndicator.isHidden = true
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitAction(_ sender: Any) {
        if (!locationText.hasText || !linkText.hasText) {
            showToast(message: "Please specify location and link!")
            return
        }
        
        progressIndicator.isHidden = false
        progressIndicator.startAnimating()
        CLGeocoder().geocodeAddressString(locationText.text!) { (placemarks, error) in
            let geocodedResult = placemarks?[0]
            if (error != nil || placemarks?.isEmpty ?? true) {
                self.progressIndicator.isHidden = true
                self.showToast(message: "Sorry, Bad location")
                return
            }
            
            guard let vc = self.storyboard?.instantiateViewController(identifier: "MapInfoPostingViewController") as? MapInfoPostingViewController else {
                return
            }
            vc.placemark = geocodedResult
            vc.link = self.linkText.text
            vc.mapString = self.locationText.text
            self.navigationController?.pushViewController(vc, animated: true)
            self.progressIndicator.isHidden = true
        }
    }
}
