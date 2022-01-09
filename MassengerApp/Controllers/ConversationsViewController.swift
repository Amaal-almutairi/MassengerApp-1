//
//  ConversationsViewController.swift
//  MassengerApp
//
//  Created by Amaal almutairi on 02/01/2022.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

final class ConversationsViewController: UIViewController{

    var identifier = "conveCell"

    private var loginObserver: NSObjectProtocol?
    
    private let spinner = JGProgressHUD(style: .dark)

   private var conversations = [Conversation]()

    
    @IBOutlet weak var tabelview: UITableView!
    @IBOutlet weak var nomessage: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Chat"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Profile", style: .done, target:self, action: #selector(profileVCTapped))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(adduserAction))
        
       // tabelview.isHidden = true
      //  nomessage.isHidden = true
        tabelview.delegate = self
       tabelview.dataSource = self
        fetchConversations()
        startListeningForCOnversations()
       
               loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
                   guard let strongSelf = self else {
                       return
                   }

                   strongSelf.startListeningForCOnversations()
               })
    }
    // Do any additional setup after loading the view.
    private func fetchConversations(){
            // fetch from firebase and either show table or label
            
            tabelview.isHidden = false
          //  nomessage.isHidden = false
        }
    @objc func profileVCTapped() {
        
        let profilevc = self.storyboard?.instantiateViewController(identifier: "profilID") as! profilVC
        self.navigationController?.pushViewController(profilevc, animated: true)
        
    }
   
    
    @objc func adduserAction() {
        
        let vc = NewConversation()
                let navVC = UINavigationController(rootViewController: vc)
        vc.completion = { [weak self] result in
                   guard let strongSelf = self else {
                       return
                   }
            
            let currentConversations = strongSelf.conversations

                       if let targetConversation = currentConversations.first(where: {
                           $0.otherUserEmail == DatabaseManger.safeEmail(emailAddress: result.email)
                       }) {
                           let vc = chatVC(with: targetConversation.otherUserEmail, id: targetConversation.id)
                           vc.isNewConversation = false
                           vc.title = targetConversation.name
                           vc.navigationItem.largeTitleDisplayMode = .never
                           strongSelf.navigationController?.pushViewController(vc, animated: true)
                       }
                       else { strongSelf.createNewConversation(result: result)
                       }
                   }
            present(navVC,animated: true)
      /*
        let loginVC = self.storyboard?.instantiateViewController(identifier: "newconv") as! NewConversation
        
        //  nav.modalPresentationStyle = .fullScreen
        self.present(loginVC, animated: false)
    
       */
    }
    private func createNewConversation(result: SearchResult) {
            let name = result.name
            let email = DatabaseManger.safeEmail(emailAddress: result.email)

            // check in datbase if conversation with these two users exists
            // if it does, reuse conversation id
            // otherwise use existing code
        DatabaseManger.shared.conversationExists(with: email, completion: { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                switch result {
                case .success(let conversationId):
                    let vc = chatVC(with: email, id: conversationId)
                    vc.isNewConversation = false
                    vc.title = name
                    vc.navigationItem.largeTitleDisplayMode = .never
                    strongSelf.navigationController?.pushViewController(vc, animated: true)
                case .failure(_):
                    let vc = chatVC(with: email, id: nil)
                    vc.isNewConversation = true
                    vc.title = name
                    vc.navigationItem.largeTitleDisplayMode = .never
                    strongSelf.navigationController?.pushViewController(vc, animated: true)
                }
            })
        }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser == nil {
            let loginVC = self.storyboard?.instantiateViewController(identifier: "signInID") as! LoginViewController
            let nav = UINavigationController(rootViewController: loginVC)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: false)
        }
    }
    private func startListeningForCOnversations() {
           guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
               return
           }

           if let observer = loginObserver {
               NotificationCenter.default.removeObserver(observer)
           }

           print("starting conversation fetch...")

           let safeEmail = DatabaseManger.safeEmail(emailAddress: email)

           DatabaseManger.shared.getAllConversations(for: safeEmail, completion: { [weak self] result in
               switch result {
               case .success(let conversations):
                   print("successfully got conversation models")
                   guard !conversations.isEmpty else {
                       self?.tabelview.isHidden = true
                       self?.nomessage.isHidden = false
                       return
                   }
                   self?.nomessage.isHidden = true
                   self?.tabelview.isHidden = false
                   self?.conversations = conversations

                   DispatchQueue.main.async {
                       self?.tabelview.reloadData()
                   }
               case .failure(let error):
                   self?.tabelview.isHidden = true
                   self?.nomessage.isHidden = false
                   print("failed to get convos: \(error)")
               }
           })
       }
    
   
    
}


extension ConversationsViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return  conversations.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        let cell = tabelview.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
          as! ConversationCustomCell
        
        cell.configure(with: model)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           tableView.deselectRow(at: indexPath, animated: true)
           let model = conversations[indexPath.row]
           openConversation(model)
       }

    func openConversation(_ model: Conversation) {
            let vc = chatVC(with: model.otherUserEmail, id: model.id)
            vc.title = model.name
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        }
  
    
   
    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let chatVC = chatV()
        let cell = tableView.cellForRow(at: indexPath)!
        chatVC.title = cell.textLabel?.text
        chatVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(chatVC, animated: true)
    }
     */
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return 120
       }

       func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
           return .delete
       }

       func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
           if editingStyle == .delete {
               // begin delete
               let conversationId = conversations[indexPath.row].id
               tableView.beginUpdates()
               self.conversations.remove(at: indexPath.row)
               tableView.deleteRows(at: [indexPath], with: .left)

               DatabaseManger.shared.deleteConversation(conversationId: conversationId, completion: { success in
                   if !success {
                       // add model and row back and show error alert
                   }
               })

               tableView.endUpdates()
           }
       }
}




