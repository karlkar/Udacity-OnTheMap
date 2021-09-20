
import UIKit

class TabBarViewController : UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        refreshAction(self)
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.udacityNetworkHelper.performSignOut(resultHandler: { success in
            if (success) {
                self.navigationController?.popToRootViewController(animated: true)
            }
        })
    }
    
    @IBAction func addAction(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(identifier: "InfoPostingNavigationController") else {
            print("Couldn't create view controller")
            return
        }
        navigationController?.present(vc, animated: true, completion: {
            self.refreshAction(self)
        })
    }
    
    @IBAction func refreshAction(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.udacityNetworkHelper.getStudentLocations { (success, locations) in
            if (success) {
                appDelegate.studentLocations = locations!
                self.refreshChildren()
            }
        }
    }
    
    private func refreshChildren() {
        guard let viewControllers = viewControllers else {
            return
        }
        for vc in viewControllers {
            if let listener = vc as? LocationUpdateListener {
                listener.onLocationsUpdated()
            }
        }
    }
}

protocol LocationUpdateListener {
    func onLocationsUpdated()
}
