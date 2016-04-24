//
//  TextBox.swift
//  AnonMessenger
//
//  Created by Christopher Wood on 4/23/16.
//  Copyright © 2016 CWoodMadeIt. All rights reserved.
//

import UIKit

protocol TextBoxDelegate: UITextViewDelegate
{
    
}

// minimum height: 60
class TextBox: UIView
{
    var delegate: TextBoxDelegate!
    
    private var textView: UITextView!
    private let PADDING: CGFloat = 5
    
    convenience init(frame: CGRect, delegate: TextBoxDelegate) {
        self.init(frame: frame)
        
        self.delegate = delegate
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        self.textView = UITextView(frame: CGRect(x: PADDING, y: PADDING, width: self.bounds.width-2*PADDING, height: self.bounds.height-2*PADDING))
        self.textView.delegate = self.delegate
        self.textView.returnKeyType = UIReturnKeyType.Send
        self.addSubview(self.textView)
    }
}
