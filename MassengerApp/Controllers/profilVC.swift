//
//  profilVC.swift
//  MassengerApp
//
//  Created by Amaal almutairi on 02/01/2022.
//

import UIKit
import FirebaseAuth
import SDWebImage

class profilVC: UIViewController {
  
    @IBOutlet weak var imgeProfil: UIImageView!
    @IBOutlet weak var userLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "profile"
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        setProfileImage(email)
        userLbl.text = email
        imgeProfil.layer.masksToBounds = true
        imgeProfil.layer.cornerRadius = imgeProfil.bounds.width / 2
    }
   
    @IBAction func logoutbtn(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
       do {
         try firebaseAuth.signOut()
           DispatchQueue.main.async {
            
               self.navigationController?.popToRootViewController(animated: true)
           
           }
       } catch let signOutError as NSError {
           
          
         print("Error signing out: %@", signOutError)
       }
         
        
    }
    func setProfileImage(_ email: String) {
        let safeEmail = DatabaseManger.safeEmail(emailAddress: email)
        let fileName = "\(safeEmail)_profile_picture.png"
        let path = "images/\(fileName)"
        
        StorageManager.shared.downloadURL(for: path, completion: {result in
            switch result {
            case .success(let url):
                self.imgeProfil.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person.circle"))
            case .failure(let error):
                print(error)
            }
        })
    }

    

}
