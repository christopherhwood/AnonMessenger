//
//  Utils.swift
//  AnonMessenger
//
//  Created by Christopher Wood on 4/18/16.
//  Copyright © 2016 CWoodMadeIt. All rights reserved.
//

import UIKit

let iOS = (UIDevice.currentDevice().systemVersion as NSString).floatValue
let STATUS_BAR_HEIGHT = (UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.Portrait || UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.PortraitUpsideDown) ? UIApplication.sharedApplication().statusBarFrame.height : UIApplication.sharedApplication().statusBarFrame.width

let TAB_BAR_HEIGHT = iOS > 8.0 ? 49 : 56
let NAV_BAR_HEIGHT = 64 - STATUS_BAR_HEIGHT
let SCREEN_WIDTH = UIScreen.mainScreen().bounds.width
let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.height
let SCALE_2X = UIScreen.mainScreen().bounds.width/320

let WhiteColor = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)