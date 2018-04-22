//
//  Extentions.swift
//  gSwitch
//
//  Created by Cody Schrank on 4/18/18.
//  Copyright © 2018 CodySchrank. All rights reserved.
//

import Cocoa

@IBDesignable
class HyperlinkTextField: NSTextField {
    @IBInspectable var href: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let attributes: [NSAttributedStringKey: Any] = [
            .foregroundColor: NSColor.blue,
            .underlineStyle: NSUnderlineStyle.styleSingle.rawValue
        ]
        self.attributedStringValue = NSAttributedString(string: self.stringValue, attributes: attributes)
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        NSWorkspace.shared.open(URL(string: href)!)
    }
}

@IBDesignable
class HyperlinkTextFieldNoURL: NSTextField {
    @IBInspectable var href: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let attributes: [NSAttributedStringKey: Any] = [
            .foregroundColor: NSColor.blue,
            .underlineStyle: NSUnderlineStyle.styleSingle.rawValue
        ]
        self.attributedStringValue = NSAttributedString(string: self.stringValue, attributes: attributes)
    }
}
