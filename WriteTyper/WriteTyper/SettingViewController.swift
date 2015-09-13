//
//  SettingViewController.swift
//  WriteTyper
//
//  Created by Eular on 9/13/15.
//  Copyright © 2015 Eular. All rights reserved.
//

import Cocoa

class SettingViewController: NSViewController {

    @IBOutlet weak var dockBtn: NSButton!
    @IBOutlet weak var startupBtn: NSButton!
    var showShare = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.boolForKey("showIcon") {
            dockBtn.state = NSOnState
        } else {
            dockBtn.state = NSOffState
        }
        
        if defaults.boolForKey("launchStartup") {
            startupBtn.state = NSOnState
        } else {
            startupBtn.state = NSOffState
        }
        self.view.frame.size.height = 352
        
        if applicationIsInStartUpItems() {
            startupBtn.state = NSOnState
        } else {
            startupBtn.state = NSOffState
        }
    }
    
    /* 
        applicationIsInStartUpItems()
        itemReferencesInLoginItems()
        toggleLaunchAtStartup()
        refs: http://stackoverflow.com/questions/26475008/swift-getting-a-mac-app-to-launch-on-startup
    */
    func applicationIsInStartUpItems() -> Bool {
        return (itemReferencesInLoginItems().existingReference != nil)
    }
    
    func itemReferencesInLoginItems() -> (existingReference: LSSharedFileListItemRef?, lastReference: LSSharedFileListItemRef?) {
        if let appUrl : NSURL = NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath) {
            let loginItemsRef = LSSharedFileListCreate(
                nil,
                kLSSharedFileListSessionLoginItems.takeRetainedValue(),
                nil
                ).takeRetainedValue() as LSSharedFileListRef?
            if loginItemsRef != nil {
                let loginItems: NSArray = LSSharedFileListCopySnapshot(loginItemsRef, nil).takeRetainedValue() as NSArray
                //print("There are \(loginItems.count) login items")
                let lastItemRef: LSSharedFileListItemRef = loginItems.lastObject as! LSSharedFileListItemRef
                for var i = 0; i < loginItems.count; ++i {
                    let currentItemRef: LSSharedFileListItemRef = loginItems.objectAtIndex(i) as! LSSharedFileListItemRef
                    
                    if let resUrl = LSSharedFileListItemCopyResolvedURL(currentItemRef, 0, nil){
                        let urlRef: NSURL = resUrl.takeRetainedValue()
                        //print("URL Ref: \(urlRef.lastPathComponent!)")
                        if urlRef.isEqual(appUrl) {
                            return (currentItemRef, lastItemRef)
                        }
                    } else {
                        //print("Unknown login application")
                    }
                }
                //The application was not found in the startup list
                return (nil, lastItemRef)
            }
        }
        return (nil, nil)
    }
    
    func toggleLaunchAtStartup() {
        let itemReferences = itemReferencesInLoginItems()
        let shouldBeToggled = (itemReferences.existingReference == nil)
        let loginItemsRef = LSSharedFileListCreate(
            nil,
            kLSSharedFileListSessionLoginItems.takeRetainedValue(),
            nil
            ).takeRetainedValue() as LSSharedFileListRef?
        if loginItemsRef != nil {
            if shouldBeToggled {
                if let appUrl : CFURLRef = NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath) {
                    LSSharedFileListInsertItemURL(
                        loginItemsRef,
                        itemReferences.lastReference,
                        nil,
                        nil,
                        appUrl,
                        nil,
                        nil
                    )
                    print("Application was added to login items")
                }
            } else {
                if let itemRef = itemReferences.existingReference {
                    LSSharedFileListItemRemove(loginItemsRef,itemRef);
                    print("Application was removed from login items")
                }
            }
        }
    }
    
    @IBAction func goGithub(sender: AnyObject) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "http://github.com/urinx")!)
    }
    
    @IBAction func setDockIcon(sender: AnyObject) {
        let btn = sender as! NSButton
        let defaults = NSUserDefaults.standardUserDefaults()
        switch btn.state {
            case NSOnState:
                toggleDockIcon(showIcon: true)
                defaults.setBool(true, forKey: "showIcon")
            case NSOffState:
                toggleDockIcon(showIcon: false)
                defaults.setBool(false, forKey: "showIcon")
            default:
                break
        }
    }
    
    @IBAction func setLaunch(sender: AnyObject) {
        toggleLaunchAtStartup()
    }
    
    @IBAction func share(sender: AnyObject) {
        if showShare {
            self.view.frame.size.height = 585
        } else {
            self.view.frame.size.height = 352
        }
        showShare = !showShare
    }
    
    @IBAction func quit(sender: AnyObject) {
        NSApplication.sharedApplication().terminate(self)
    }
    
}
