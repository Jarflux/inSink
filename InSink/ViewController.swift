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
    var lastProcessedId : Int64 = 0
    var secondPartMoveEventId = ""
    var aemUser = "admin"
    var aemPassword = "admin"
    
    var userDefaults = NSUserDefaults.standardUserDefaults()
    
    @IBAction func start(sender: AnyObject) {
        writeToLog("Started Sync")
        if configIsValidToRun(){
            startButton.enabled = false
            stopButton.enabled = true
            
            monitor = FileSystemEventMonitor(
                pathsToWatch: directories,
                latency: 1,
                watchRoot: true,
                queue: dispatch_get_main_queue()) { (events:[FileSystemEvent])->() in
                    self.handleEvents(events)
            }
        }
    }
    
    @IBAction func stop(sender: AnyObject) {
        monitor = nil
        startButton.enabled = true
        stopButton.enabled = false
        writeToLog("Stopped Sync")
    }
    
    @IBAction func saveOptions(sender: AnyObject) {
        extensions = parseExtensionsInput(extensionsTextField.stringValue)
        userDefaults.setObject(extensionsTextField.stringValue, forKey:"extensions")
        
        directories = parseDirectoriesInput(directoriesTextField.stringValue)
        userDefaults.setObject(directoriesTextField.stringValue, forKey:"directories")

        ignoredPaths = parseDirectoriesInput(ignoredPathsTextField.stringValue)
        userDefaults.setObject(ignoredPathsTextField.stringValue, forKey:"ignoredPaths")
        
        userDefaults.synchronize()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(userDefaults.stringForKey("extensions") != nil){
            self.extensions  = parseExtensionsInput(userDefaults.stringForKey("extensions")!)
            extensionsTextField.stringValue = userDefaults.stringForKey("extensions")!
        }
        if(userDefaults.stringForKey("directories") != nil){
            self.directories  = parseDirectoriesInput(userDefaults.stringForKey("directories")!)
            directoriesTextField.stringValue = userDefaults.stringForKey("directories")!
        }
        if(userDefaults.stringForKey("ignoredPaths") != nil){
            self.ignoredPaths = parseDirectoriesInput(userDefaults.stringForKey("ignoredPaths")!)
            ignoredPathsTextField.stringValue = userDefaults.stringForKey("ignoredPaths")!
        }

    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    //Tested
    func parseExtensionsInput(input : String) -> [String]{
        return input.stringByReplacingOccurrencesOfString(" ", withString: "").stringByReplacingOccurrencesOfString(".", withString: "").componentsSeparatedByString(",")
    }
    
    //Tested
    func parseDirectoriesInput(input : String) -> [String]{
        return input.stringByReplacingOccurrencesOfString(" ", withString: "").componentsSeparatedByString(",")
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
    
    func handleEvents(events: [FileSystemEvent]) {
        for event in events{
            if debug{
                writeToLog("--> Captured event " + event.description);
            }
            if eventIsNotHandledBefore(Int64(event.ID)){
                handleEvent(event)
            }
        }
    }
    
    //Tested
    func eventIsNotHandledBefore(id: Int64) -> Bool{
        if(id > lastProcessedId){
            return true
        }
        return false
    }
    
    enum EventFlag: String{
        case FlagItemCreated = "ItemCreated"
        case FlagItemRemoved = "ItemRemoved"
        case FlagItemCreatedRemoved = "ItemCreated, ItemRemoved"
        case FlagItemRenamedChangeOwner = "ItemRenamed, ItemChangeOwner"
        case FlagItemMetaModifiedChangeOwner = "ItemInodeMetaMod, ItemModified, ItemChangeOwner"
        case FlagItemCreatedRemovedModified = "ItemCreated, ItemRemoved, ItemModified"
        case FlagItemInodeMetaMod = "ItemInodeMetaMod"
        case FlagItemRenamed = "ItemRenamed"
        case FlagItemModified = "ItemModified"
    }
    
    func handleEvent(event: FileSystemEvent) {
        if  pathContainsJrcRoot(event.path) &&  hasCorrectExtension(event.path) && pathIsNotIgnored(event.path){
            if debug{
                writeToLog("--> Handling event " + event.description)
            }
            switch event.flag.description {
            case EventFlag.FlagItemCreated.rawValue:
                handleCreatedEvent(event)
            case EventFlag.FlagItemRemoved.rawValue:
                handleRemovedEvent(event)
            case EventFlag.FlagItemCreatedRemoved.rawValue:
                handleRemovedEvent(event)
            case EventFlag.FlagItemRenamedChangeOwner.rawValue:
                handleModifiedEvent(event)
            case EventFlag.FlagItemMetaModifiedChangeOwner.rawValue:
                handleModifiedEvent(event)
            case EventFlag.FlagItemCreatedRemovedModified.rawValue:
                handleModifiedEvent(event)
            case EventFlag.FlagItemInodeMetaMod.rawValue:
                handleModifiedEvent(event)
            case EventFlag.FlagItemRenamed.rawValue:
                handleRenamedEvent(event)
            case EventFlag.FlagItemModified.rawValue:
                handleModifiedEvent(event)
            default:
                writeToLog("--> NEW EVENT VALUE FOUND " + String(event.flag.description) + " for path " + event.path)
            }
        }
        lastProcessedId = Int64(event.ID)
    }
    
    func handleCreatedEvent(event : FileSystemEvent){
        if debug{
            writeToLog("--> Handle Create event" + event.description)
        }
        pushFileToRemote(event.path)
    }
    
    func handleRemovedEvent(event : FileSystemEvent){
        if debug{
            writeToLog("--> Handle Removed event" + event.description)
        }
        removeFileFromRemote(event.path)
    }
    
    func handleModifiedEvent(event : FileSystemEvent){
        if debug{
            writeToLog("--> Handle Modified event" + event.description)
        }
        pushFileToRemote(event.path)
    }
    
    func handleRenamedEvent(event : FileSystemEvent){
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
    func getJrcPath(path:String) -> String {
        return path.componentsSeparatedByString("/jcr_root")[1]
    }
    
    func pushFileToRemote(path: String) {
        let remote = "http://localhost:4502" + getJrcPath(path)
        let url = NSURL(string:remote)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "PUT"
        request.HTTPBody = NSData(contentsOfFile: path)
        Alamofire.request(request).authenticate(user: aemUser, password: aemPassword)
            .responseData { response in
                if response.result.isSuccess {
                    self.writeStatusToLog("PUSH", result: true, dest: remote)
                }
                if response.result.isFailure {
                    self.writeStatusToLog("PUSH", result: false, dest: remote)
                    self.writeToLog("Response " + String(response))
                }
        }
    }
    
    func removeFileFromRemote(path : String){
        let remote = "http://localhost:4502" + getJrcPath(path)
        let url = NSURL(string:remote)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "DELETE"
        Alamofire.request(request).authenticate(user: aemUser, password: aemPassword)
            .responseData { response in
                if response.result.isSuccess {
                    self.writeStatusToLog("DELETE", result: true, dest: remote)
                }
                if response.result.isFailure {
                    self.writeStatusToLog("DELETE", result: false, dest: remote)
                    self.writeToLog("Response " + String(response))
                }
        }
    }
    
    //Tested
    func pathContainsJrcRoot(path: String) -> Bool {
        if path.containsString("/jcr_root/"){
            return true
        }
        if debug {
            writeToLog("--> jcr_root not found in path " + path)
        }
        return false
    }
    
    func pathIsNotIgnored(path: String) -> Bool {
        for ignore in ignoredPaths{
            if path.containsString(ignore){
                if debug {
                    writeToLog("--> Ignored Path '" + path +  "' found in path " + path)
                }
                return false
            }
        }
        return true
    }
    
    //Tested
    func hasCorrectExtension(path: String) -> Bool {
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
        let dayTimePeriodFormatter = NSDateFormatter()
        dayTimePeriodFormatter.dateFormat = "yyy-MM-dd HH:mm:ss"
        return dayTimePeriodFormatter.stringFromDate(NSDate())
    }
    
    func writeStatusToLog(action: String, result: Bool, dest: String ){
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
    
    func writeToLog(statement: String){
        logView.textStorage!.mutableString.appendString(statement + "\n")
        logView.scrollRangeToVisible(NSMakeRange(logView.textStorage!.length,0))
    }
    
    
}