//
//  ProfileSettingViewController.swift
//  Hyphenate Messenger
//
//  Created by Yi Jerry on 2017-09-26.
//  Copyright © 2017 Hyphenate Inc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import MBProgressHUD
class ProfileSettingViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Firebase
    //var ref: DatabaseReference!
    var ref = Database.database().reference()
    var uid = "+1" + EMClient.shared().currentUsername!
    
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.frame.size.width/1.74
        
        imageView.clipsToBounds = true

        
        // get profile picture from DB
        self.ref.child("users").child(uid).child("profilepicURL").observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.exists(){
                let val = snapshot.value as? String
                if (val == nil){
                    self.imageView.image = #imageLiteral(resourceName: "profile")
                }
                else{
                    let profileUrl = URL(string: val!)
                    //print(val)
                    self.imageView.sd_setImage(with: profileUrl)
                }
            }
        }) { (error) in print(error.localizedDescription)}
    }
    
    
    // MARK: - Title
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
 
    
    
    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK - Interaction
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let imageData: Data = UIImagePNGRepresentation(imageView.image!)!
        uploadPicture(imageData, completion:{ (url) -> Void in
            self.ref.child("users/\(self.uid)").updateChildValues(["profilepicURL": url!])
            MBProgressHUD.hide(for: self.view, animated: true)
            self.navigationController?.popViewController(animated: true)
            
            //label.removeFromSuperview()
        })
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageView.image = info[UIImagePickerControllerOriginalImage] as! UIImage?
        //self.profilePic = info[UIImagePickerControllerOriginalImage] as! UIImage?
        dismiss(animated: true, completion: nil)
    }
    
    
    func uploadPicture(_ data: Data, completion:@escaping (_ url: String?) -> ()) {
        let storageRef = Storage.storage().reference()
        storageRef.child("image/profilePicture/\(self.uid)").putData(data, metadata: nil){(metaData,error) in
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
            }else{
                //store downloadURL
                completion((metaData?.downloadURL()?.absoluteString)!)
            }
        }
    }
    
    func handleTap(_ tapGesture: UITapGestureRecognizer) {
        let actionSheet = UIAlertController(title: "Upload Profile Picture", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title:"Choose from Albumn", style: .default, handler:{(action:UIAlertAction) in self.pickPhoto()}))
        
        actionSheet.addAction(UIAlertAction(title:"Cancel", style: .cancel, handler:nil))
        self.present(actionSheet, animated: true, completion: nil)

    }

    
    
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let actionSheet = UIAlertController(title: "Upload Profile Picture", message: nil, preferredStyle: .actionSheet)
//        
//        actionSheet.addAction(UIAlertAction(title:"Choose from Albumn", style: .default, handler:{(action:UIAlertAction) in self.pickPhoto()}))
//        
//        actionSheet.addAction(UIAlertAction(title:"Cancel", style: .cancel, handler:nil))
//        self.present(actionSheet, animated: true, completion: nil)
//        
//    }
    
    func pickPhoto(){
        let imagePicker = UIImagePickerController()
        present(imagePicker, animated: true, completion: nil)
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    


    
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
