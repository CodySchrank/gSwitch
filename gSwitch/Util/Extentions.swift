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

/*
Checks to see if the string is contained in the group of strings
 
 - returns:
true if the string was in the group, else false
 
*/
extension String {
    func any(_ group: [String]) -> Bool {
        var atLeastOneInGroup = false
        
        for str in group {
            if self.contains(str) {
                atLeastOneInGroup = true
                break
            }
        }
        
        return atLeastOneInGroup
    }
}

/*
 Checks to see if any string is contained in the group of strings
 
 - returns:
 true if any string was in the group, else false
 
 */
extension Array where Element == String {
    func any(_ group: [String]) -> Bool {
        var anyInGroup = false
        
        for str in group {
            if str.any(self) {
                anyInGroup = true
                break
            }
        }
        
        return anyInGroup
    }
}

class OnlyIntegerValueFormatter: NumberFormatter {
    override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        
        // Ability to reset your field (otherwise you can't delete the content)
        // You can check if the field is empty later
        if partialString.isEmpty {
            return true
        }
        
        // Optional: limit input length
        /*
         if partialString.characters.count>3 {
         return false
         }
         */
        
        // Actual check
        return Int(partialString) != nil
    }
}
