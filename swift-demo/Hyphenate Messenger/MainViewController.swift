
import UIKit

class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let contactsViewController: ContactsTableViewController = ContactsTableViewController();
        let contactsRootViewController:UINavigationController = UINavigationController(rootViewController: contactsViewController)
        
        let conversationsViewController:ConversationsTableViewController = ConversationsTableViewController()
        let conversationRootViewController:UINavigationController = UINavigationController(rootViewController: conversationsViewController)
        
        //Ming: added session tab for past sessions
        let sessionsViewController:ConversationsTableViewController = ConversationsTableViewController()
        let sessionsRootViewController:UINavigationController = UINavigationController(rootViewController: sessionsViewController)
        
        let settingsViewController:SettingsTableViewController = SettingsTableViewController()
        let settingsRootViewController:UINavigationController = UINavigationController(rootViewController: settingsViewController)
        
        self.setViewControllers([contactsRootViewController, conversationRootViewController, sessionsRootViewController, settingsRootViewController], animated: true)
        
        let contactsTabItem:UITabBarItem = self.tabBar.items![0]
        contactsTabItem.image = UIImage(named:  "contactsTab")
        contactsTabItem.selectedImage = UIImage(named:  "contactsTab_selected")
        contactsTabItem.imageInsets = UIEdgeInsetsMake(8, 0, -8, 0);
        
        let conversationsTabItem:UITabBarItem = self.tabBar.items![1]
        conversationsTabItem.image = UIImage(named:  "chatsTab")
        conversationsTabItem.selectedImage = UIImage(named:  "chatsTab_selected")
        conversationsTabItem.imageInsets = UIEdgeInsetsMake(8, 0, -8, 0);
        
        //Ming: added session tab for past sessions
        let sessionsTabItem:UITabBarItem = self.tabBar.items![2]
        sessionsTabItem.image = UIImage(named: "sessionsTab")
        sessionsTabItem.selectedImage = UIImage(named: "sessionsTab_selected")
        sessionsTabItem.imageInsets = UIEdgeInsetsMake(8, 0, -8, 0)

        let settingsTabItem:UITabBarItem = self.tabBar.items![3]
        settingsTabItem.image = UIImage(named:  "settingsTab")
        settingsTabItem.selectedImage = UIImage(named:  "settingsTab_selected")
        settingsTabItem.imageInsets = UIEdgeInsetsMake(8, 0, -8, 0);

        UITabBar.appearance().tintColor = UIColor.hiPrimary()
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.updateUnreadMessageCount), name: NSNotification.Name(rawValue: "kNotification_unreadMessageCountUpdated"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUnreadMessageCount()
    }

    func updateUnreadMessageCount() {
        let conversations: [EMConversation] = EMClient.shared().chatManager.getAllConversations() as! [EMConversation]
        var unreadCount: Int = 0
        conversations.forEach { (conversation) in
            unreadCount = unreadCount + Int(conversation.unreadMessagesCount)
        }
        
        if unreadCount > 0 {
            self.tabBar.items![1].badgeValue = "\(unreadCount)"
        } else {
            self.tabBar.items![1].badgeValue = nil
        }
        
        UIApplication.shared.applicationIconBadgeNumber = unreadCount
    }
}
