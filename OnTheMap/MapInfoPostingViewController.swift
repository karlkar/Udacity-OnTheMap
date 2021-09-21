
import UIKit
import MapKit

class MapInfoPostingViewController: UIViewController, MKMapViewDelegate {
    
    var link: String? = nil
    var mapString: String? = nil
    var placemark: CLPlacemark? = nil
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        guard let placemark = placemark else {
            print("Sorry, invalid data - placemark")
            return
        }
        
        guard let chosenLocation = placemark.location?.coordinate else {
            print("Sorry, invalid data - location")
            return
        }
        
        let pinOfChosenPlace = MKPointAnnotation()
        pinOfChosenPlace.coordinate = chosenLocation
        mapView.addAnnotation(pinOfChosenPlace)
        
        mapView.centerCoordinate = chosenLocation
        
        guard let region = placemark.region as? CLCircularRegion else {
            print("Sorry, invalid data - region")
            return
        }
        let mkregion = MKCoordinateRegion(center: region.center, latitudinalMeters: region.radius*2, longitudinalMeters: region.radius*2)
        mapView.setRegion(mkregion, animated: true)
    }
    
    @IBAction func finishAction(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.udacityNetworkHelper.getProfileData { (success, userData) in
            if !success {
                print("Sorry, I failed to get the profile data...")
                self.showToast(message: "Oh man! I failed to get your profile data. Bad, bad me :/")
                return
            }
            
            appDelegate.udacityNetworkHelper.postStudentLocation(
                uniqueKey: appDelegate.udacityNetworkHelper.clientAccountId!,
                firstName: userData!.firstName,
                lastName: userData!.lastName,
                mapString: self.mapString!,
                mediaUrl: self.link!,
                latitude: self.placemark!.location!.coordinate.latitude,
                longitude: self.placemark!.location!.coordinate.longitude) { (success) in
                if success {
                    print("Success!")
                    
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.showToast(message: "Oh man! Posting failed :/")
                    print("Failure!")
                }
            }
        }
    }
}
