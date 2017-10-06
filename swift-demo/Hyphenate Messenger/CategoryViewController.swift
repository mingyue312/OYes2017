//
//  ViewController.swift
//  MenuChoice
//
//  Created by juanmao on 16/2/16.
//  Copyright © 2016年 juanmao. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController {

    var productTypeArr:[String] = []
    var productNameArr:[AnyObject] = []
    var classifyTable: GroupTableView?
    var navController: UINavigationController? = nil
    var picture: UIImage? = nil
    var imageview: UIImageView = UIImageView(frame: CGRect(x: 0, y: 68, width: screenWidth, height: screenHeight*0.37))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Category"
        self.view.backgroundColor = UIColor.white
        self.initData()
        self.automaticallyAdjustsScrollViewInsets = false

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(DismissMenu))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
//        self.navigationController?.navigationBar.tintColor = UIColor.white
//        self.navigationBar.barStyle = UIBarStyle.Black
//        self.navigationBar.tintColor = UIColor.whiteColor()
//        navigationController?.navigationBar.barTintColor = UIColor.black
//        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        setupimageview()

    }

    func setupimageview(){
        imageview.contentMode = .scaleAspectFit
        imageview.image = picture
        imageview.backgroundColor = UIColor.white
        
        view.addSubview(imageview)
    }
    
    func DismissMenu(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //This is code from online. It is gathering the data from MenuData.json to know what categories to display.
    func  initData()
    {
        self.addSubView()
    }

//  Create the GroupTableView and present it. GroupTableView is the double menu table style.
    func addSubView(){
//            调用时传入frame和数据源
        classifyTable = GroupTableView(frame: CGRect(x: 0,y: 211,width: screenWidth,height: screenHeight-211))
        classifyTable?.navController = self.navController
        classifyTable?.picture.image = picture
        self.view.addSubview(classifyTable!)
    }
    
}

