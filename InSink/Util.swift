//
//  Util.swift
//  InSink
//
//  Created by Ben Oeyen on 30/03/2017.
//  Copyright © 2017 Ben Oeyen. All rights reserved.
//

import Cocoa

class Util{

    //Tested
    static func sanitizeInput(_ input : String) -> [String]{
        return input.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: ".", with: "").components(separatedBy: ",")
    }
    
    //Tested
    static func parseCommaSepartedString(_ input : String) -> [String]{
        var dirs = input.components(separatedBy: ",")
        for i in 0..<dirs.count {
            dirs[i] = dirs[i].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        return dirs
    }

    static func black() -> NSColor{
        return NSColor.init(red:0, green:0, blue:0, alpha:1);
    }
    
    static func red() -> NSColor{
        return NSColor.init(srgbRed:244/255, green:67/255, blue:54/255, alpha:1.0);
    }
    
    static func green() -> NSColor{
        return NSColor.init(srgbRed:76/255, green:175/255, blue:80/255, alpha:1.0);
    }
    
    static func timeStamp() -> String {
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "yyy-MM-dd HH:mm:ss"
        return dayTimePeriodFormatter.string(from: Date())
    }
}
