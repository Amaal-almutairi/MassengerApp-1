
import UIKit
import Firebase
import FirebaseAuth
import JGProgressHUD


protocol RegisterDelegate:AnyObject {
    func rgisterSuccss()
}

class RegisterViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    weak var mydelegate:RegisterDelegate?
    //   var FN: String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailLbl.delegate = self
        passwordLbl.delegate = self
        
        logoIMG.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(didTapChangeProfilePic))
        
        logoIMG.addGestureRecognizer(gesture)
        logoIMG.layer.masksToBounds = true
        logoIMG.layer.cornerRadius = logoIMG.bounds.width / 2
        
        
    }
    
    @objc private func didTapChangeProfilePic() {
        presentPhotoActionSheet()
    }
    
    @IBOutlet weak var logoIMG: UIImageView!
    
    @IBOutlet weak var firstNameLbl: UITextField!
    
    @IBOutlet weak var lastNameLbl: UITextField!
    
    @IBOutlet weak var emailLbl: UITextField!
    
    @IBOutlet weak var passwordLbl: UITextField!
    
    
    func registerButtonTapped() {
        emailLbl.resignFirstResponder()
        passwordLbl.resignFirstResponder()
        firstNameLbl.resignFirstResponder()
        lastNameLbl.resignFirstResponder()
        
        
    }
    
    
    
    @IBAction func Registerbtn(_ sender: UIButton) {
        guard let firstName = firstNameLbl.text,
              let lastName = lastNameLbl.text,
              let email = emailLbl.text,
              let password = passwordLbl.text,
              !email.isEmpty,
              !password.isEmpty,
              !firstName.isEmpty,
              !lastName.isEmpty,
              password.count >= 6 else {
                  //   alertUserLoginError()
                  return
              }
        spinner.show(in: view)
        
        if let email = emailLbl.text,let password = passwordLbl.text {
            DatabaseManger.shared.userExists(with: email, completion: { [weak self] exists in
                guard let strongSelf = self else {
                    return
                }
                
                guard !exists else {
                    // user already exists
                    strongSelf.alertUserLoginError(message: "Looks like a user account for that email address already exists.")
                    return
                }
                UserDefaults.standard.setValue(email, forKey: "email")
                UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "name")
                
                
                Auth.auth().createUser(withEmail: email, password: password, completion: { authResult , error  in
                    
                    DispatchQueue.main.async {
                        strongSelf.spinner.dismiss()
                    }
                    guard let result = authResult, error == nil else {
                        print("Error creating user \(error?.localizedDescription)")
                        return
                    }
                    
                    let user = result.user
                    print("Create User: \(user)")
                    
                    
                    
                  
                    let chatUser = ChatAppUser (firstName: firstName,
                                                lastName: lastName,
                                                emailAddress: email)
                    
                    DatabaseManger.shared.insertUser(with: chatUser, completion: {succcess in
                        if succcess {
                            guard let image = strongSelf.logoIMG.image,
                                  let data = image.pngData() else {
                                      return
                                  }
                            let fileName = chatUser.profilePicture
                            StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName, completion: {
                                result in
                                switch result{
                                case . success(let downloadURL):
                                    UserDefaults.standard.set(downloadURL, forKey: "profilePicture")
                                    print(downloadURL)
                                case .failure(let error):
                                    print("Storage manger error : \(error)")
                                }
                            })
                        }
                        
                    } )
                    
                    DispatchQueue.main.async {
                        self?.mydelegate?.rgisterSuccss()
                        strongSelf.navigationController?.popViewController(animated: true)
                        
                    }
                    
                    
                    print("Created User: \(user)")
                })
            }
                                             
            )}
        
        
    }
    
}

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailLbl {
            passwordLbl.becomeFirstResponder()
        }
        else if textField == passwordLbl {
            registerButtonTapped()
        }
        
        return true
    }
    
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "How would you like to select a picture?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
            
            self?.presentCamera()
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Chose Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
            
            self?.presentPhotoPicker()
            
        }))
        
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        self.logoIMG.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    
    func alertUserLoginError(message: String = "Please enter all information to create a new account.") {
        let alert = UIAlertController(title: "information",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"Cancel",
                                      style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
}

