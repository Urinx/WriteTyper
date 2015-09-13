//
//  AppDelegate.swift
//  WriteTyper
//
//  Created by Eular on 9/12/15.
//  Copyright © 2015 Eular. All rights reserved.
//

import Cocoa
import AVFoundation

func toggleDockIcon(showIcon state: Bool) -> Bool {
    var result: Bool
    if state {
        result = NSApp.setActivationPolicy(NSApplicationActivationPolicy.Regular)
    }
    else {
        result = NSApp.setActivationPolicy(NSApplicationActivationPolicy.Accessory)
    }
    return result
}


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(30)
    let popover = NSPopover()
    var avPlayer: AVAudioPlayer!

    // システム環境設定に設定変更を依頼する
    func acquirePrivileges() -> Bool {
        let accessEnabled = AXIsProcessTrustedWithOptions(
            [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true])
        if !accessEnabled {
            print("You need to enable the WriteTyper in the System Prefrences")
        }
        return accessEnabled
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        let isAcquirePrivileges = acquirePrivileges()
        
        if isAcquirePrivileges {
            NSEvent.addGlobalMonitorForEventsMatchingMask(
                NSEventMask.KeyDownMask, handler: {(theEvent: NSEvent) in
                    let key = theEvent.keyCode
                    self.playSoundsByKey(key)
            })
        } else {
            let alert = NSAlert()
            alert.window.title = "WriteTyper"
            alert.messageText = "Help"
            alert.informativeText = "For it to work: Accessibility for WriteTyper must be enabled in Security & Privacy, System Preferences.\n\nMade by Urinx, based on original NoisyTyper"
            alert.runModal()
        }
        
        // Add menu bar icon
        if let button = statusItem.button {
            button.image = NSImage(named: "typewriter")
            button.action = Selector("togglePopover:")
        }
        
        popover.contentViewController = SettingViewController(nibName: "SettingViewController", bundle: nil)
        
        // Dock Icon
        let defaults = NSUserDefaults.standardUserDefaults()
        toggleDockIcon(showIcon: defaults.boolForKey("showIcon"))
    }
    
    func showPopover(sender: AnyObject?) {
        if let button = statusItem.button {
            popover.showRelativeToRect(button.bounds, ofView: button, preferredEdge: .MinY)
        }
    }
    
    func closePopover(sender: AnyObject?) {
        popover.performClose(sender)
    }
    
    func togglePopover(sender: AnyObject?) {
        if popover.shown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
    func playSoundsByKey(key: UInt16) {
        var rate:Float = 1.0
        var pan:Float = 0.0
        var volume:Float = 0.5
        var sound = "key-new-01"
        
        switch key {
        case 125: // scrollDown
            rate = ofRandom(0.85, max: 1.0)
            pan = -0.7
            volume = 1.0
            sound = "scrollDown"
        case 126: // scrollUp
            rate = ofRandom(0.85, max: 1.0)
            pan = -0.7
            volume = 1.0
            sound = "scrollUp"
        case 51: // backspace
            rate = ofRandom(0.97, max: 1.03)
            volume = 1.0
            pan = 0.75
            sound = "backspace"
        case 49: // space
            rate = ofRandom(0.95, max: 1.05)
            volume = ofRandom(0.8, max: 1.1)
            sound = "space-new"
        case 36: // return
            rate = ofRandom(0.99, max: 1.01)
            volume = ofRandom(0.7, max: 1.1)
            pan = 0.3
            sound = "return-new"
        default:
            rate = ofRandom(0.98, max: 1.02)
            volume = ofRandom(0.7, max: 1.1)
            sound = "key-new-0\(random() % 5 + 1)"
            
            if( key == 12 || key == 13 || key == 0 || key == 1 || key == 6 || key == 7 ) {
                pan = -0.65
            } else if( key == 35 || key == 37 || key == 43 || key == 31 || key == 40 || key == 46 ) {
                pan = 0.65
            } else {
                pan = ofRandom(-0.3, max: 0.3)
            }
        }
        
        do {
            avPlayer = try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(sound, ofType: "mp3")!))
            avPlayer.rate = rate
            avPlayer.pan = pan
            avPlayer.volume = volume
            avPlayer.play()
        } catch {}
    }
    
    func ofRandom(min: Float, max: Float) -> Float {
        return Float(arc4random()) / 0xFFFFFFFF * (max - min) + min
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

}

