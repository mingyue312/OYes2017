
import UIKit
import MessageUI
import Foundation
import Firebase
import FirebaseDatabase


class SettingsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate{
    
    var ref: DatabaseReference!
    var uid = "+1" + EMClient.shared().currentUsername!
    var profilePicURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        self.tabBarController?.navigationItem.title = "Settings"
        self.tableView = UITableView(frame: self.tableView.frame, style: .grouped)
        self.tableView.backgroundColor = UIColor.init(hex: "F0EFF5")
        self.tableView.separatorInset = .zero
        self.tableView.layoutMargins = .zero
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(UINib(nibName: "SwitchTableViewCell", bundle: nil), forCellReuseIdentifier: "switchCell")
        self.tableView.register(UINib(nibName: "LabelTableViewCell", bundle: nil), forCellReuseIdentifier: "labelCell")
        
        self.tableView.register(UINib(nibName: "ConversationTableViewCell", bundle: nil), forCellReuseIdentifier: "conversationCell")
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = "Settings"
        self.tabBarController?.tabBar.isHidden = false
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    // MARK: - Table view data source
    
    let data = [[[#imageLiteral(resourceName: "profile"),"Profile"]], [[#imageLiteral(resourceName: "balance"),"My balance"], [#imageLiteral(resourceName: "-points"),"My points"]], [[#imageLiteral(resourceName: "HelpIcon"),"Help"], [#imageLiteral(resourceName: "Feedback"),"Feedback"], [#imageLiteral(resourceName: "Rate"),"Rate us"], [#imageLiteral(resourceName: "FaceBook"),"Like us on Facebook"]],[["Log out"]]]
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section != 3{
            if indexPath.section == 0 {
                // My Profile TODO: don't use conversation table view cell, better make a new one
                let cell:ConversationTableViewCell = tableView.dequeueReusableCell(withIdentifier: "conversationCell", for: indexPath) as! ConversationTableViewCell
                cell.senderLabel.text = "Jerry"
                cell.badgeView.isHidden = true
                cell.timeLabel.isHidden = true
                cell.senderImageView.image = UIImage(named: "jerryProfile")
                cell.senderImageView.contentMode = .scaleAspectFill
                cell.lastMessageLabel.isHidden = true
                return cell
            } else{
                let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                cell.textLabel?.text = self.data[indexPath.section][indexPath.row][1] as? String
                cell.imageView?.image = self.data[indexPath.section][indexPath.row][0] as? UIImage
                
                cell.accessoryType = .disclosureIndicator
                return cell
            }
        }
        else{
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = self.data[indexPath.section][indexPath.row][0] as? String
            cell.textLabel?.textAlignment = .center
            
            return cell
            
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section{
        // section 0
        case 0:
            if indexPath.row == 0{
                let StoryBoard = UIStoryboard(name:"ProfileMain",bundle:nil)
                let myProfileVC = StoryBoard.instantiateViewController(withIdentifier: "myProfileVC")
                tabBarController?.navigationController?.pushViewController(myProfileVC, animated: true)
                //self.navigationController?.pushViewController(myProfileVC, animated: true)
                
            }
        // section 1
        case 1:
            break //TODO
        // section 2
        case 2:
            switch indexPath.row{
            // Help
            case 0:
                let openMainPageVc = OpenUrlViewController()
                openMainPageVc.url = "https://www.instasolve.ca/"
                tabBarController?.navigationController?.pushViewController(openMainPageVc, animated: true)
                self.tabBarController?.tabBar.isHidden = true
                
                
            // Feedback
            case 1:
                if !MFMailComposeViewController.canSendMail(){
                    print("Mail services are not available")
                    self.showSendMailErrorAlert()
                    return
                } else {
                    sendFeedback()
                }
            // Rate us
            case 2:
                break
            // Like us on Facebook
            case 3:
                openFacebookPage()
                tableView.deselectRow(at: indexPath, animated: true)
            default:break
            }
        // section 3
        case 3:
            tableView.deselectRow(at: indexPath, animated: true)
            createAlert()
        default:break
        }
    }
    
    // change Height of Profile Picture Cell
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0 && indexPath.row == 0){
            return 80
        }
        return 40
    }
    
    
    func logoutAction() {
        EMClient.shared().logout(false) { (error) in
            if let _ = error {
                let alert = UIAlertController(title:"Sign Out error", message: "Please try again later", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "ok"), style: .cancel, handler: nil))
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            } else {
                let loginController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginScene")
                UIApplication.shared.keyWindow?.rootViewController = loginController
                
            }
        }
    }
    
    // MARK: - Functions
    func openFacebookPage() {
        let page = "https://www.facebook.com/InstaSolve/"
        UIApplication.shared.openURL(NSURL(string: page)! as URL)
    }
    
    func presentSettingPage(){
        let settingVC = SettingsTableViewController()
        self.present(settingVC, animated: true, completion: nil)
    }
    
    func createAlert (){
        let alert = UIAlertController(title: "Log Out InstaSolve?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title:"Log Out", style: UIAlertActionStyle.default, handler:{(action:UIAlertAction) in self.logoutAction()}))
        alert.addAction(UIAlertAction(title:"Cancel", style: UIAlertActionStyle.default, handler:nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Send FeedBack Module
    // send Feedback
    func sendFeedback(){
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        // Configure the fields of the interface
        composeVC.setToRecipients(["instasolve1@gmail.com"])
        composeVC.setSubject("Feedback - InstaSolve")
        composeVC.setMessageBody("Please leave us your precious feedback!", isHTML: false)
        self.present(composeVC, animated: true, completion:nil)
    }
    
    // error handler
    func showSendMailErrorAlert(){
        let sendMailErrorAlert = UIAlertController(title: "Mail cannot be sent", message: "Mailbox is not setup properly", preferredStyle: .alert )
        sendMailErrorAlert.addAction(UIAlertAction(title: "Yes", style: .default) {_ in})
        self.present(sendMailErrorAlert, animated: true)
    }
    
    // dimiss controller
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case MFMailComposeResult.cancelled:
            print("Mail cancelled")
        case MFMailComposeResult.saved:
            print("Mail saved")
        case MFMailComposeResult.sent:
            print("Mail sent")
        case MFMailComposeResult.failed:
            print("Mail sent failure")
        default:
            break
        }
        // Dismiss mail view controller and back to setting page
        self.dismiss(animated:true, completion: nil)
    }
    
    
    func getPhotosFromStorage(from url : String){
        //print (url)
        let storageRef = Storage.storage().reference(forURL:url)
        storageRef.getData(maxSize: 2 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
            } else {
                print(data)
                //self.dictArray[index]["picURL"] = data
                //print(dic)
            }
        }
    }
    
    func getPhotoUrl(from uid : String){
        ref?.child("users").child(uid).child("profilepicURL").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let val = snapshot.value as? String
            print(val!)
            if (val! != ""){
                self.profilePicURL = val!
            } else {
                print("No profile pic Up there")
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    


    
    
}




