import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        progressIndicator.isHidden = true
    }
    
    @IBAction func signInAction(_ sender: Any) {
        if (!loginTextField.hasText || !passwordTextField.hasText) {
            showToast(message: "Error! Login or password not valid!")
            return
        }
        
        progressIndicator.isHidden = false
        progressIndicator.startAnimating()
        sendSignInRequest()
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        if let url = URL(string: "https://www.udacity.com/account/auth#!/signup") {
            UIApplication.shared.open(url)
        }
    }
    
    private func sendSignInRequest() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.udacityNetworkHelper.performSignIn(login: loginTextField.text!, password: passwordTextField.text!, resultHandler:{ success, networkError in
            if (!success) {
                self.progressIndicator.isHidden = true
                if (networkError) {
                    self.showToast(message: "Check your network!")
                } else {
                    self.showToast(message: "Oh man, Check your creds...")
                }
                return
            }
            guard let vc = self.storyboard?.instantiateViewController(identifier: "TabBarController") else {
                return
            }
            self.navigationController?.pushViewController(vc, animated: true)
            self.progressIndicator.isHidden = true
        })
    }
}

