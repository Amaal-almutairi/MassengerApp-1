//
//  ViewController.swift
//  MassengerApp
//
//  Created by Amaal almutairi on 30/12/2021.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class LoginViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Firebase Login / check to see if email is taken
        // try to create an account
        if Auth.auth().currentUser?.uid != nil {
            goToConversation()
        }
    }
    
    @IBOutlet weak var msgLbl: UILabel!
    
    @IBOutlet weak var logoIMG: UIImageView!
    
    @IBOutlet weak var emailLbl: UITextField!
    
    @IBOutlet weak var passwordLbl: UITextField!
    
    
    
    @IBAction func loginbtn(_ sender: Any) {
        loginButton()
        if let email = emailLbl.text,let password = passwordLbl.text {
            
            spinner.show(in: view)
            
            Auth.auth().signIn(withEmail: email, password: password, completion: {[weak self] authResult , error  in
                
                guard let strongSelf = self else {
                    return
                }
                DispatchQueue.main.async {
                    strongSelf.spinner.dismiss(animated: true)
                    strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                }
                guard let result = authResult, error == nil else {
                    print("Error creating user: \(error?.localizedDescription)")
                    return
                }
                
                let user = result.user
                let safeEmail = DatabaseManger.safeEmail(emailAddress: email)
                
                DatabaseManger.shared.getDataFor(path: safeEmail, completion: { result in
                    switch result {
                    case .success(let data):
                        guard let userData = data as? [String: Any],
                              let firstName = userData["first_name"] as? String,
                              let lastName = userData["last_name"] as? String else {
                                  return
                              }
                        UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
                        
                    case .failure(let error):
                        print("Failed to read data with error \(error)")
                    }
                })
                
                UserDefaults.standard.set(email, forKey: "email")
                // print("Logged In User: \(user)")
                strongSelf.goToConversation()
                
            })
            
        }
    }
    
    func goToConversation(){
        DispatchQueue.main.async {
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "convId") as! ConversationsViewController
            VC.title = "Create Account"
            self.navigationController?.pushViewController(VC, animated: true)
        }
    }
    
    @IBAction func loginfacebook(_ sender: UIButton) {
        goToConversation()
    }
    
    @IBAction func Regbtn(_ sender: UIButton) {
        
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "RegisterID") as! RegisterViewController
        VC.mydelegate = self
        VC.title = "Create Account"
        self.navigationController?.pushViewController(VC, animated: true)
        
        //ظظself.present(VC, animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    // validation
    func loginButton() {
        
        
        
        emailLbl.resignFirstResponder()
        passwordLbl.resignFirstResponder()
        
        guard let email = emailLbl.text, let password = passwordLbl.text,
              !email.isEmpty, !password.isEmpty, password.count >= 6 else {
                  //  userAlert()
                  
                  return
                  
              }
        // this is alert to complete all info
        
        func userAlert() {
            let alert = UIAlertController(title: "Information",
                                          message: "Please enter all information to log in.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:"Dismiss",
                                          style: .cancel, handler: nil))
            present(alert, animated: true)
        }
        
        
    }
    
}
/*
 extension LoginViewController: UITextFieldDelegate {
 // this function will call if the user hit return key
 func textFieldShouldReturn(_ textField: UITextField) -> Bool {
 
 if textField == emailLbl {
 passwordLbl.becomeFirstResponder()
 }
 else if textField == passwordLbl {
 loginButton()
 }
 
 return true
 }
 }
 */


extension LoginViewController:RegisterDelegate {
    func rgisterSuccss() {
        
        goToConversation()
    }
    
}
