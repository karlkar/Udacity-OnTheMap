import UIKit
import MapKit

class MapViewController : UIViewController, MKMapViewDelegate, LocationUpdateListener {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mapView.delegate = self
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.image = UIImage(named: "icon_pin")
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            pinView!.rightCalloutAccessoryView?.isHidden = true
        }
        else {
            pinView!.annotation = annotation
        }
        
        let subtitleView = UILabel()
        subtitleView.text = annotation.subtitle!
        pinView!.detailCalloutAccessoryView = subtitleView
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard var annotationSubtitle = view.annotation?.subtitle as? String else {
            print("no way! no mediaURL is set!")
            return
        }
        if !annotationSubtitle.hasPrefix("http") {
            annotationSubtitle = "http://" + annotationSubtitle
        }
        if let url = URL(string: annotationSubtitle) {
            UIApplication.shared.open(url)
        } else {
            print("no way! not a URL!")
        }
    }
    
    func onLocationsUpdated() {
        print("Locations updated!")
        
        var annotations = [MKPointAnnotation]()
        
        for location in StudentRepository.sharedInstance.studentLocations {
            let coordinate = CLLocationCoordinate2D(latitude:  CLLocationDegrees(location.latitude), longitude:  CLLocationDegrees(location.longitude))
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(location.firstName) \(location.lastName)"
            annotation.subtitle = location.mediaUrl
            
            annotations.append(annotation)
        }
        
        // When the array is complete, we add the annotations to the map.
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotations(annotations)
    }
}
