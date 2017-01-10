//
//  ViewController.swift
//  InSink
//
//  Created by Ben Oeyen on 06/05/16.
//  Copyright © 2016 Ben Oeyen. All rights reserved.
//

import Cocoa
import EonilFileSystemEvents
import Alamofire

class ViewController: NSViewController {
    
    @IBOutlet var logView: NSTextView!
    @IBOutlet var startButton: NSButton!
    @IBOutlet var stopButton: NSButton!
    @IBOutlet var recursiveToggle: NSButton!
    @IBOutlet var verboseToggle: NSButton!
    @IBOutlet var extensionsTextField: NSTextField!
    @IBOutlet var directoriesTextField: NSTextField!
    @IBOutlet var ignoredPathsTextField: NSTextField!

    var	monitor	= nil as FileSystemEventMonitor?
    var directories: [String] = []
    var extensions: [String] =  []
    var ignoredPaths: [String] = []
    var debug = false;
    var lastProcessedId : UInt64 = 0
    var secondPartMoveEventId = ""
    var aemUser = "admin"
    var aemPassword = "admin"
    
    var userDefaults = UserDefaults.standard
    
    @IBAction func start(_ sender: AnyObject) {
        writeToLog("Started Sync")
        if configIsValidToRun(){
            startButton.isEnabled = false
            stopButton.isEnabled = true
            
            monitor = FileSystemEventMonitor(
                pathsToWatch: directories,
                latency: 1,
                watchRoot: true,
                queue: DispatchQueue.main) { (events:[FileSystemEvent])->() in
                    self.handleEvents(events)
            }
        }
    }
    
    @IBAction func stop(_ sender: AnyObject) {
        monitor = nil
        startButton.isEnabled = true
        stopButton.isEnabled = false
        writeToLog("Stopped Sync")
    }
    
    @IBAction func clear(_ sender: AnyObject) {
        clearLog()
    }
    
    @IBAction func saveOptions(_ sender: AnyObject) {
        extensions = parseExtensionsInput(extensionsTextField.stringValue)
        userDefaults.set(extensionsTextField.stringValue, forKey:"extensions")
        
        directories = parseDirectoriesInput(directoriesTextField.stringValue)
        userDefaults.set(directoriesTextField.stringValue, forKey:"directories")

        ignoredPaths = parseDirectoriesInput(ignoredPathsTextField.stringValue)
        userDefaults.set(ignoredPathsTextField.stringValue, forKey:"ignoredPaths")
        
        userDefaults.synchronize()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(userDefaults.string(forKey: "extensions") != nil){
            self.extensions  = parseExtensionsInput(userDefaults.string(forKey: "extensions")!)
            extensionsTextField.stringValue = userDefaults.string(forKey: "extensions")!
        }
        if(userDefaults.string(forKey: "directories") != nil){
            self.directories  = parseDirectoriesInput(userDefaults.string(forKey: "directories")!)
            directoriesTextField.stringValue = userDefaults.string(forKey: "directories")!
        }
        if(userDefaults.string(forKey: "ignoredPaths") != nil){
            self.ignoredPaths = parseDirectoriesInput(userDefaults.string(forKey: "ignoredPaths")!)
            ignoredPathsTextField.stringValue = userDefaults.string(forKey: "ignoredPaths")!
        }

    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    //Tested
    func parseExtensionsInput(_ input : String) -> [String]{
        return input.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: ".", with: "").components(separatedBy: ",")
    }
    
    //Tested
    func parseDirectoriesInput(_ input : String) -> [String]{
        var dirs = input.components(separatedBy: ",")
        for i in 0..<dirs.count {
            dirs[i] = dirs[i].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        return dirs
    }
    
    func configIsValidToRun() -> Bool {
        if ( directories.count < 1){
            writeToLog("Invalid config: no directories found");
            return false
        }
        if ( extensions.count < 1 ){
            writeToLog("Invalid config: no extensions found");
            return false
        }
        return true
    }
    
    func handleEvents(_ events: [FileSystemEvent]) {
        for event in events{
            if debug{
                writeToLog("--> Captured event " + event.description);
            }
            if eventIsNotHandledBefore(UInt64(event.ID)){
                handleEvent(event)
            }
        }
    }
    
    //Tested
    func eventIsNotHandledBefore(_ id: UInt64) -> Bool{
        if(id > lastProcessedId){
            return true
        }
        return false
    }
    
    enum EventFlag: String{
        case FlagItemCreated = "ItemCreated"
        case FlagItemRemoved = "ItemRemoved"
        case FlagItemInodeMetaMod = "ItemInodeMetaMod"
        case FlagItemRenamed = "ItemRenamed"
        case FlagItemModified = "ItemModified"
        case FlagItemXattrMod = "ItemXattrMod"
        case FlagItemChangeOwner = "ItemChangeOwner"
        case FlagItemFinderInfoMod = "ItemFinderInfoMod"
    }
    
    func parseLastEventFromRawValue(_ input : String) -> String{
        var eventsArray = input.replacingOccurrences(of: " ", with: "").components(separatedBy: ",")
        return eventsArray[eventsArray.count-1]
    }
    
    func handleEvent(_ event: FileSystemEvent) {
        if  pathContainsJrcRoot(event.path) &&  hasCorrectExtension(event.path) && pathIsNotIgnored(event.path){
            if debug{
                writeToLog("--> Handling event " + event.description)
            }
                   
            switch parseLastEventFromRawValue(event.flag.description) {
            case EventFlag.FlagItemCreated.rawValue:
                handleCreatedEvent(event)
            case EventFlag.FlagItemRemoved.rawValue:
                handleRemovedEvent(event)
            case EventFlag.FlagItemInodeMetaMod.rawValue:
                handleModifiedEvent(event)
            case EventFlag.FlagItemRenamed.rawValue:
                handleRenamedEvent(event)
            case EventFlag.FlagItemModified.rawValue:
                handleModifiedEvent(event)
            case EventFlag.FlagItemXattrMod.rawValue:
                handleModifiedEvent(event)
            case EventFlag.FlagItemChangeOwner.rawValue:
                handleModifiedEvent(event)
            case EventFlag.FlagItemFinderInfoMod.rawValue:
                handleModifiedEvent(event)
            default:
                writeToLog("--> NEW EVENT VALUE FOUND " + String(event.flag.description) + " for path " + event.path)
            }
            
        }
        lastProcessedId = UInt64(event.ID)
    }
    
    func handleCreatedEvent(_ event : FileSystemEvent){
        if debug{
            writeToLog("--> Handle Create event" + event.description)
        }
        pushFileToRemote(event.path)
    }
    
    func handleRemovedEvent(_ event : FileSystemEvent){
        if debug{
            writeToLog("--> Handle Removed event" + event.description)
        }
        removeFileFromRemote(event.path)
    }
    
    func handleModifiedEvent(_ event : FileSystemEvent){
        if debug{
            writeToLog("--> Handle Modified event" + event.description)
        }
        pushFileToRemote(event.path)
    }
    
    func handleRenamedEvent(_ event : FileSystemEvent){
        if(secondPartMoveEventId != String(event.ID)){
            if debug{
                writeToLog("--> Handle Create event part 1" + event.description)
            }
            removeFileFromRemote(event.path)
            secondPartMoveEventId = String(event.ID + 1)
        }else{
            if debug{
                writeToLog("--> Handle Rename event part 2" + event.description)
            }
            pushFileToRemote(event.path)
            secondPartMoveEventId = ""
        }
    }
    
    //Tested
    func getJrcPath(_ path:String) -> String {
        return path.components(separatedBy: "/jcr_root")[1]
    }
    
    func pushFileToRemote(_ path: String) {
        let remote = "http://localhost:4502" + getJrcPath(path)
        let url = URL(string:remote)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "PUT"
        request.httpBody = try? Data(contentsOf: URL(fileURLWithPath: path))
        Alamofire.upload(URL(fileURLWithPath: path), to: url!, method: .put).authenticate(user: aemUser, password: aemPassword)
            .responseData { response in
                if response.result.isSuccess {
                    self.writeStatusToLog("PUSH", result: true, dest: remote)
                }
                if response.result.isFailure {
                    self.writeStatusToLog("PUSH", result: false, dest: remote)
                    self.writeToLog("Response " + String(describing: response))
                }
        }
    }
    
    func removeFileFromRemote(_ path : String){
        let remote = "http://localhost:4502" + getJrcPath(path)
        let url = URL(string:remote)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "DELETE"
        Alamofire.request(request as! URLRequestConvertible).authenticate(user: aemUser, password: aemPassword)
            .responseData { response in
                if response.result.isSuccess {
                    self.writeStatusToLog("DELETE", result: true, dest: remote)
                }
                if response.result.isFailure {
                    self.writeStatusToLog("DELETE", result: false, dest: remote)
                    self.writeToLog("Response " + String(describing: response))
                }
        }
    }
    
    //Tested
    func pathContainsJrcRoot(_ path: String) -> Bool {
        if path.contains("/jcr_root/"){
            return true
        }
        if debug {
            writeToLog("--> jcr_root not found in path " + path)
        }
        return false
    }
    
    func pathIsNotIgnored(_ path: String) -> Bool {
        for ignore in ignoredPaths{
            if path.contains(ignore){
                if debug {
                    writeToLog("--> Ignored Path '" + path +  "' found in path " + path)
                }
                return false
            }
        }
        return true
    }
    
    //Tested
    func hasCorrectExtension(_ path: String) -> Bool {
        for ext in extensions{
            if path.hasSuffix("." + ext){
                return true
            }
        }
        if debug {
            writeToLog("--> No required extension found in path " + path)
        }
        return false
    }
    
    func timeStamp() -> String {
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "yyy-MM-dd HH:mm:ss"
        return dayTimePeriodFormatter.string(from: Date())
    }
    
    func writeStatusToLog(_ action: String, result: Bool, dest: String ){
        if result{
            //let myMutableString = NSMutableAttributedString(string: timeStamp() + " " + action + " SUCCESS "  + dest)
            //myMutableString.addAttribute(NSForegroundColorAttributeName, value: NSColor.greenColor(), range: NSRange(location:0,length:String(myMutableString).characters.count))
            writeToLog(timeStamp() + " " + action + " SUCCESS "  + dest);
        }else{
           // let myMutableString = NSMutableAttributedString(string: timeStamp() + " " + action + " FAILED "  + dest)
           // myMutableString.addAttribute(NSForegroundColorAttributeName, value: NSColor.redColor(), range: NSRange(location:0,length:String(myMutableString).characters.count))
            writeToLog(timeStamp() + " " + action + " FAILED "  + dest);
        }
        
    }
    
    func writeToLog(_ statement: String){
        logView.textStorage!.mutableString.append(statement + "\n")
        logView.scrollRangeToVisible(NSMakeRange(logView.textStorage!.length,0))
    }
    
    func clearLog(){
        logView.textStorage!.mutableString.setString("")
    }
    
    
}
