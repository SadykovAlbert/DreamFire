

import UIKit

class GroupViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        return cell
    }
    

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createGroupSegue" {
            guard let dvc = segue.destination as? NewGroupViewController else {return}
            dvc.segueChoise = .registrationGroup
        }
        else if segue.identifier == "showDetailGroup" {
            guard let dvc = segue.destination as? NewGroupViewController else {return}
            dvc.segueChoise = .profileGroup
        }
    }
    

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "createGroupSegue", sender: nil)
    }
    

}
