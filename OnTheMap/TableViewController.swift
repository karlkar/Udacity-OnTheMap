import UIKit

class TableViewController: UITableViewController, LocationUpdateListener {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func onLocationsUpdated() {
        print("Locations updated!")
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentRepository.sharedInstance.studentLocations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let studentLocation = StudentRepository.sharedInstance.studentLocations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentLocationCell")
        cell?.textLabel?.text = studentLocation.firstName + " " + studentLocation.lastName
        cell?.detailTextLabel?.text = studentLocation.mediaUrl
        cell?.imageView?.image = UIImage(named: "icon_pin")
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentLocation = StudentRepository.sharedInstance.studentLocations[indexPath.row]
        var annotationSubtitle = studentLocation.mediaUrl
        if !annotationSubtitle.hasPrefix("http") {
            annotationSubtitle = "http://" + annotationSubtitle
        }
        if let url = URL(string: annotationSubtitle) {
            UIApplication.shared.open(url)
        } else {
            print("no way! not a URL!")
        }
    }
}
