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
    
    @IBAction func exportConfig(_ sender: AnyObject){
        var exportedConfig = ""
        if(userDefaults.string(forKey: "extensions") != nil){
            exportedConfig = exportedConfig + userDefaults.string(forKey: "extensions")!
        }
        exportedConfig = exportedConfig + ";_;"
        if(userDefaults.string(forKey: "projectRoot") != nil){
            exportedConfig = exportedConfig +  userDefaults.string(forKey: "projectRoot")!
        }
        exportedConfig = exportedConfig + ";_;"
        if(userDefaults.string(forKey: "modules") != nil){
            exportedConfig = exportedConfig +  userDefaults.string(forKey: "modules")!
        }
        exportedConfig = exportedConfig + ";_;"
        if(userDefaults.string(forKey: "excludedPaths") != nil){
            exportedConfig = exportedConfig + userDefaults.string(forKey: "excludedPaths")!
        }
        
        let alert = NSAlert()
        alert.messageText = "Configuration String"
        alert.addButton(withTitle: "Close")
        alert.informativeText = exportedConfig;
        alert.beginSheetModal(for: self.view.window!, completionHandler: nil )
    }
    
    @IBAction func importConfig(_ sender: AnyObject){
        let importedConfig = getStringFromDialog()
        if(importedConfig != nil){
            var configs = importedConfig!.components(separatedBy: ";_;")
            if(configs.count == 4){
                userDefaults.set(configs[0], forKey:"extensions")
                userDefaults.set(configs[1], forKey:"projectRoot")
                userDefaults.set(configs[2], forKey:"modules")
                userDefaults.set(configs[3], forKey:"excludedPaths")
                viewDidLoad()
            }
        }
    }
    
    func getStringFromDialog() -> String? {
        let dialog = NSAlert()
        dialog.addButton(withTitle: "Import")  // 1st button
        dialog.addButton(withTitle: "Cancel")  // 2nd button
        dialog.messageText = "Import Config"
        dialog.informativeText = "Enter Configuration String"
        
        let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 400, height: 200))
        txt.stringValue = ""
        
        dialog.accessoryView = txt
        let response: NSModalResponse = dialog.runModal()
        
        if (response == NSAlertFirstButtonReturn) {
            return txt.stringValue
        } else {
            return nil
        }
    }
    
    override func viewDidLoad() {
        if(userDefaults.string(forKey: "extensions") != nil){
            self.extensions = parseExtensionsInput(userDefaults.string(forKey: "extensions")!)
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

