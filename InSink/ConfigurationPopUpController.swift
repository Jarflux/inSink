//
//  ConfigurationPopUpController.swift
//  InSink
//
//  Created by Ben Oeyen on 29/03/2017.
//  Copyright © 2017 Ben Oeyen. All rights reserved.
//

import Cocoa

class ConfigurationPopUpController: NSViewController {
    
    @IBOutlet var extensionsTextField: NSTextField!
    @IBOutlet var projectRootTextField: NSTextField!
    @IBOutlet var modulesTextField: NSTextField!
    @IBOutlet var excludedPathsTextField: NSTextField!

    var extensions: [String] =  []
    var projectRoot: String = ""
    var modules: [String] = []
    var excludedPaths: [String] = []
    
    var userDefaults = UserDefaults.standard
    
    @IBAction func closeWindow(_ sender: AnyObject) {
        self.view.window?.close()
    }
    
    @IBAction func saveOptionsAndCloseWindow(_ sender: AnyObject) {
        extensions = parseExtensionsInput(extensionsTextField.stringValue)
        userDefaults.set(extensionsTextField.stringValue, forKey:"extensions")
        
        projectRoot = projectRootTextField.stringValue
        userDefaults.set(projectRootTextField.stringValue, forKey:"projectRoot")
        
        modules = parseModulesInput(modulesTextField.stringValue)
        userDefaults.set(modulesTextField.stringValue, forKey:"modules")
        
        excludedPaths = parseModulesInput(excludedPathsTextField.stringValue)
        userDefaults.set(excludedPathsTextField.stringValue, forKey:"excludedPaths")
        
        userDefaults.synchronize()
        self.view.window?.close()
    }
    
    override func viewDidLoad() {
        if(userDefaults.string(forKey: "extensions") != nil){
            self.extensions  = parseExtensionsInput(userDefaults.string(forKey: "extensions")!)
            extensionsTextField.stringValue = userDefaults.string(forKey: "extensions")!
        }
        if(userDefaults.string(forKey: "projectRoot") != nil){
            self.projectRoot  = userDefaults.string(forKey: "projectRoot")!
            projectRootTextField.stringValue = userDefaults.string(forKey: "projectRoot")!
        }
        if(userDefaults.string(forKey: "modules") != nil){
            self.modules = parseModulesInput(userDefaults.string(forKey: "modules")!)
            modulesTextField.stringValue = userDefaults.string(forKey: "modules")!
        }
        if(userDefaults.string(forKey: "excludedPaths") != nil){
            self.excludedPaths = parseModulesInput(userDefaults.string(forKey: "excludedPaths")!)
            excludedPathsTextField.stringValue = userDefaults.string(forKey: "excludedPaths")!
        }
    }
    
    //Tested
    func parseExtensionsInput(_ input : String) -> [String]{
        return input.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: ".", with: "").components(separatedBy: ",")
    }
    
    //Tested
    func parseModulesInput(_ input : String) -> [String]{
        var dirs = input.components(separatedBy: ",")
        for i in 0..<dirs.count {
            dirs[i] = dirs[i].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        return dirs
    }
    
    
}

