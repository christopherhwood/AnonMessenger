//
//  HomeViewController.swift
//  AnonMessenger
//
//  Created by Christopher Wood on 4/18/16.
//  Copyright © 2016 CWoodMadeIt. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController
{
    
    // Variables
    
    private var contactsTableView: UITableView!
    private var oldPeepsArray: Array<UserModel>!
    private var newPeepsArray: Array<UserModel>!
    
    // Functions
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if NSUserDefaults.standardUserDefaults().objectForKey("username") == nil
        {
            self.promptUserName()
        }
        self.createView()
    }
    
    private func createView()
    {
        self.navigationController?.title = "Welcome"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: #selector(HomeViewController.promptUserName))
        
        let bgView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        bgView.backgroundColor = WhiteColor
        self.view.addSubview(bgView)
        
        contactsTableView = UITableView.init(frame: CGRect(x: bgView.bounds.minX, y: bgView.bounds.minY, width: bgView.bounds.width, height: bgView.bounds.height), style: UITableViewStyle.Plain)
        contactsTableView.registerClass(PeepCell.self, forCellReuseIdentifier: "PEEP")
        contactsTableView.delegate = self
        contactsTableView.dataSource = self
        bgView.addSubview(contactsTableView)
    }
    
    internal func promptUserName()
    {
        let alertController = UIAlertController(title: "Login", message: "Please enter a username", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addTextFieldWithConfigurationHandler { (textField: UITextField) in
            textField.delegate = self
            textField.placeholder = "Your awesome username"
        }
    }
    
    func openChatWindow(user: UserModel)
    {
        let chatViewController = ChatViewController(peep: user)
        navigationController?.pushViewController(chatViewController, animated: true)
    }
}

extension HomeViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        NSUserDefaults.standardUserDefaults().setObject(textField.text, forKey: "username")
        return true
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return newPeepsArray.count
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "New Peeps"
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 150
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        self.openChatWindow(newPeepsArray[indexPath.row])
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("PEEPCELL") as! PeepCell
        cell.peep = newPeepsArray[indexPath.row]
        return cell
        
    }
}