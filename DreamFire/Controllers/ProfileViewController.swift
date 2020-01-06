

import UIKit
import Firebase


class ProfileViewController: UIViewController {
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var buttonOutlet: UIButton!
    @IBOutlet weak var rBarButtonItemOutlet: UIBarButtonItem!
    
    var friend: AppUser?
    let ref = Database.database().reference().child("users")
    
    enum whichSegue {
        case registration
        case profile
        case friend
    }
    
    var segueChoise: whichSegue = .profile
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    //
    func setupUI(){
        
        switch segueChoise {
        case .registration:
            setupRegistration()
        case .profile:
            setupProfile()
        case .friend:
            setupFriend()
        }
    }
    
    func setupRegistration(){
        buttonOutlet.setTitle("Registrate", for: .normal)
       // rBarButtonItemOutlet.title = "Registrate"
      //  navigationItem.title = "Registration"
    
    }
    
    func setupProfile(){
        
        
        buttonOutlet.setTitle("Save", for: .normal)
        guard let user = Auth.auth().currentUser else {return}
        let ref3 = Database.database().reference(withPath: "users").child(String(user.uid))
        ref3.observe(.value) { (snapshot) in
            
            let userApp = AppUser(snapshot: snapshot)
    
            self.nameTextField.text = userApp.name
            self.firstNameTextField.text = userApp.lastName
            self.loginTextField.text = userApp.email
            self.passwordTextField.text = userApp.password
        

        }
        
    }
    
    func setupFriend(){
        buttonOutlet.setTitle("Add to Friends", for: .normal)
        passwordTextField.isHidden = true
        nameTextField.isEnabled = false
        firstNameTextField.isEnabled = false
        loginTextField.isEnabled = false
        
        loginTextField.text = friend?.email
        nameTextField.text = friend?.name
        firstNameTextField.text = friend?.lastName
        
        buttonOutlet.setTitle("Dismiss", for: .normal)
        
        
      
        
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        
        switch segueChoise {
        case .registration:
            registrateButtonTapped()
        case .profile:
            saveButtonTapped()
        case .friend:
            addToFriendButtonTapped()
            
        
        }
    }
    
    func registrateButtonTapped(){
        
        guard let email = loginTextField.text,
            let password = passwordTextField.text,
            let name = nameTextField.text,
            let lastName = firstNameTextField.text,
            name != "",
            lastName != "",
            email != "",
            password != "" else {
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: {[weak self]  (authResult, error) in
            
            guard error == nil , let user = authResult?.user else {
                print(error!.localizedDescription)
                return
            }
            
            let ref2 = Database.database().reference(withPath: "users").child(String(user.uid))
            
            let myUser = AppUser(user: user, name: name, lastName: lastName, password: password)
     
            ref2.setValue(myUser.convertToDictionary())
            
            
            self?.performSegue(withIdentifier: "finishregSegue", sender: nil)
        })
    }
    func saveButtonTapped(){
        guard let user = Auth.auth().currentUser else {return}
        guard let name = self.nameTextField.text,
            let firstname = self.firstNameTextField.text,
            let password = self.passwordTextField.text
            else {return}
        
        let userApp = AppUser(user: user,
                              name: name,
                              lastName: firstname,
                              password: password)
        ref.child(user.uid).setValue(userApp.convertToDictionary())
    }
    func addToFriendButtonTapped(){
        dismiss(animated: true, completion: nil)
    }
    
}
