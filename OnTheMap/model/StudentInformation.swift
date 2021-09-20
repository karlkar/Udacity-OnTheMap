import Foundation

struct StudentInformation {
    let createdAt: String
    let firstName: String
    let lastName: String
    let latitude: Double
    let longitude: Double
    let mapString: String
    let mediaUrl: String
    let objectId: String
    let uniqueKey: String
    let updatedAt: String
    
    init(dict: [String: AnyObject]) {
        self.createdAt = dict["createdAt"] as! String
        self.firstName = dict["firstName"] as! String
        self.lastName = dict["lastName"] as! String
        self.latitude = Double(truncating: dict["latitude"] as! NSNumber)
        self.longitude = Double(truncating: dict["longitude"] as! NSNumber)
        self.mapString = dict["mapString"] as! String
        self.mediaUrl = (dict["mediaURL"] as? String) ?? ""
        self.objectId = dict["objectId"] as! String
        self.uniqueKey = (dict["uniqueId"] as? String) ?? ""
        self.updatedAt = (dict["updatedAt"] as? String) ?? ""
    }
}
