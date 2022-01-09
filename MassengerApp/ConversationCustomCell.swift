//
//  customCellProfil.swift
//  MassengerApp
//
//  Created by Amaal almutairi on 02/01/2022.
//

import UIKit
import SDWebImage

class ConversationCustomCell: UITableViewCell {

    
    @IBOutlet weak var profilIMG: UIImageView!
    
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var userMessageLabel: UILabel!
    
   
   
    public func configure(with model: Conversation) {
        
         userMessageLabel.text = model.latestMessage.text
           titleLbl.text = model.name
          
        
           let path = "images/\(model.otherUserEmail)_profile_picture.png"
           StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
               switch result {
               case .success(let url):

                   DispatchQueue.main.async {
                       self?.profilIMG.sd_setImage(with: url, completed: nil)
                   }

               case .failure(let error):
                   print("failed to get image url: \(error)")
               }
           })
       }

}
