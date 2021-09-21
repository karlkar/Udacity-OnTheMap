
import Foundation

typealias StudentRepository = SingletonIsAnAntiPattern

class SingletonIsAnAntiPattern {
    
    static let sharedInstance = SingletonIsAnAntiPattern()
    
    var studentLocations: [StudentInformation] = []
    
    private init() {}
}
