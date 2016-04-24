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
    private var peepsArray: Array<UserModel>!
    
    // Functions
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.peepsArray = DataStorage.sharedInstance.listUsersSortedByUnreadMessages()
        
        if NSUserDefaults.standardUserDefaults().objectForKey("username") == nil
        {
            self.promptUserName()
        }
        self.createView()
    }
    
    private func createView()
    {
        self.navigationController?.title = "Peeps"
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
    
    func promptUserName()
    {
        let alertController = UIAlertController(title: "Login", message: "Please enter a username", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addTextFieldWithConfigurationHandler { (textField: UITextField) in
            textField.delegate = self
            textField.placeholder = "Your awesome username"
        }
        self.presentViewController(alertController, animated: true, completion: nil)
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
        if let username = textField.text where username.characters.count > 0
        {
            NSUserDefaults.standardUserDefaults().setObject(username, forKey: "username")
            Socket.sharedInstance.login(username, completionHandler: { (success) in
                if success == false
                {
                    let alert = UIAlertController.init(title: "Error", message: "Sorry, there was an error setting your name", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) in
                        self.promptUserName()
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
            return true
        }
        else
        {
            let alert = UIAlertController.init(title: "Error", message: "You need to enter a username", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) in
                self.promptUserName()
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        return true
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return peepsArray.count
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 50
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        self.openChatWindow(peepsArray[indexPath.row])
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("PEEPCELL") as! PeepCell
        cell.peep = peepsArray[indexPath.row]
        return cell
    }
}

extension HomeViewController: DataStorageUserDelegate
{
    func didChangeUserArray()
    {
        self.peepsArray = DataStorage.sharedInstance.listUsersSortedByUnreadMessages()
        self.contactsTableView.reloadData()
    }
}