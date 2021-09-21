
import Foundation

class UdacityNetworkHelper {
    
    private var clientSessionId: String? = nil
    var clientAccountId: String? = nil
    
    private func doOnMainThread(resultHandler: @escaping () -> ()) {
        DispatchQueue.main.async {
            resultHandler()
        }
    }
    
    func performSignIn(login: String, password: String, resultHandler: @escaping (_ success: Bool, _ networkError: Bool) -> ()) {
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // encoding a JSON body from a string, can also use a Codable struct
        request.httpBody = "{\"udacity\": {\"username\": \"\(login)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                print("Error occurred!")
                self.doOnMainThread {
                    resultHandler(false, true)
                }
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                self.doOnMainThread {
                    resultHandler(false, false)
                }
                return
            }
            
            let range = 5..<data!.count
            let newData = data?.subdata(in: range) /* subset response data! */
            print(String(data: newData!, encoding: .utf8)!)
            
            guard let data = newData else {
                print("No data was returned by the request!")
                self.doOnMainThread {
                    resultHandler(false, false)
                }
                return
            }
            
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                self.doOnMainThread {
                    resultHandler(false, false)
                }
                return
            }
            
            guard let parsedCheckedResult = parsedResult else {
                print("Parsing failed")
                self.doOnMainThread {
                    resultHandler(false, false)
                }
                return
            }
            guard let sessionData = parsedCheckedResult["session"] else {
                print("Session object not found")
                self.doOnMainThread {
                    resultHandler(false, false)
                }
                return
            }
            guard let accountData = parsedCheckedResult["account"] else {
                print("Account object not found")
                self.doOnMainThread {
                    resultHandler(false, false)
                }
                return
            }
            
            self.clientSessionId = sessionData["id"] as? String
            self.clientAccountId = accountData["key"] as? String
            
            self.doOnMainThread {
                resultHandler(self.clientSessionId != nil, false)
            }
        }
        task.resume()
    }
    
    func performSignOut(resultHandler: @escaping (_ success: Bool) -> ()) {
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                self.doOnMainThread {
                    resultHandler(false)
                }
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                self.doOnMainThread {
                    resultHandler(false)
                }
                return
            }
            
            let range = 5..<data!.count
            let newData = data?.subdata(in: range)
            print(String(data: newData!, encoding: .utf8)!)
            self.clientSessionId = nil
            self.clientAccountId = nil
            self.doOnMainThread {
                resultHandler(true)
            }
        }
        task.resume()
    }
    
    
    func getProfileData(resultHandler: @escaping (_ success: Bool, _ data: UdacityUserData?) -> ()) {
        if (self.clientSessionId == nil || self.clientAccountId == nil) {
            print("No way! Login first!")
            return
        }
        
        let request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/users/\(clientAccountId ?? "")")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error...
                self.doOnMainThread {
                    resultHandler(false, nil)
                }
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                self.doOnMainThread {
                    resultHandler(false, nil)
                }
                return
            }
            
            let range = 5..<data!.count
            let newData = data?.subdata(in: range) /* subset response data! */
            
            guard let data = newData else {
                print("No data was returned by the request!")
                self.doOnMainThread {
                    resultHandler(false, nil)
                }
                return
            }
            print(String(data: newData!, encoding: .utf8)!)
            
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                self.doOnMainThread {
                    resultHandler(false, nil)
                }
                return
            }
            
            let userData = UdacityUserData(firstName: parsedResult["first_name"] as! String, lastName: parsedResult["last_name"] as! String)
            self.doOnMainThread {
                resultHandler(true, userData)
            }
        }
        task.resume()
    }
    
    func getStudentLocations(resultHandler: @escaping (_ success: Bool, _ data: [StudentInformation]?) -> ()) {
        let request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/StudentLocation?order=-updatedAt&limit=100")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error...
                self.doOnMainThread {
                    resultHandler(false, nil)
                }
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                self.doOnMainThread {
                    resultHandler(false, nil)
                }
                return
            }
            
            guard let data = data else {
                print("No data was returned by the request!")
                self.doOnMainThread {
                    resultHandler(false, nil)
                }
                return
            }
            print(String(data: data, encoding: .utf8)!)
            
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                self.doOnMainThread {
                    resultHandler(false, nil)
                }
                return
            }
            
            let results = parsedResult["results"] as! [[String: AnyObject]]
            var studentLocations : [StudentInformation] = []
            for item in results {
                studentLocations.append(StudentInformation(dict: item))
            }
            self.doOnMainThread {
                resultHandler(true, studentLocations)
            }
            
        }
        task.resume()
    }
    
    func postStudentLocation(uniqueKey: String, firstName: String, lastName: String, mapString: String, mediaUrl: String, latitude: Double, longitude: Double, resultHandler: @escaping (_ success: Bool) -> ()) {
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaUrl)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                self.doOnMainThread {
                    resultHandler(false)
                }
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                self.doOnMainThread {
                    resultHandler(false)
                }
                return
            }
            
            print(String(data: data!, encoding: .utf8)!)
            
            self.doOnMainThread {
                resultHandler(true)
            }
        }
        task.resume()
    }
    
    func putStudentLocation(uniqueKey: String, firstName: String, lastName: String, mapString: String, mediaUrl: String, latitude: Float, longitude: Float, resultHandler: @escaping (_ success: Bool) -> ()) {
        let urlString = "https://onthemap-api.udacity.com/v1/StudentLocation/8ZExGR5uX8"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaUrl)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                self.doOnMainThread {
                    resultHandler(false)
                }
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                self.doOnMainThread {
                    resultHandler(false)
                }
                return
            }
            
            print(String(data: data!, encoding: .utf8)!)
            
            self.doOnMainThread {
                resultHandler(true)
            }
        }
        task.resume()
    }
}
