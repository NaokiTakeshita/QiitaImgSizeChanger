//
//  AppDelegate.swift
//  qiitaImgSizeChanger
//
//  Created by Naoki Takeshita on 2021/05/13.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    // pasteboard
    var timer: Timer!
    let pasteboard: NSPasteboard = NSPasteboard.general
    var changeCount: Int = 0
    var countIgnorPasteboardMessage = 0
    
    // アイコンflash
    var timerFlash : Timer?
    var flashCount = 0
    
    // ステータスバーメニュー
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
    
    // 追加アクション用
    var canAcceptAction = false
    
    // 設定用
    var acceptQuickPaste = false
    var defaultWithString = ""
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        let userDefaults = UserDefaults.standard
        userDefaults.register(defaults: ["QuickPaste" : false,
                                         "DefaultWidth" : "60%"])
        
        acceptQuickPaste = userDefaults.bool(forKey: "QuickPaste")
        if let defaultWidth = userDefaults.string(forKey: "DefaultWidth"){
            defaultWithString = defaultWidth
            print(defaultWithString)
        }
//        userDefaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
//        userDefaults.synchronize()
        
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (t) in
            if self.changeCount != self.pasteboard.changeCount {
                self.changeCount = self.pasteboard.changeCount
                NotificationCenter.default.post(name: .pasteboardDidChange, object: self.pasteboard)
            }
        }
        
        createMenu()
        
        
        countIgnorPasteboardMessage = NSPasteboard.general.changeCount
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onPasteboardChanged),
                                               name: .pasteboardDidChange,
                                               object: nil)
        
    }
    
    func createMenu(){
        if let button = statusItem.button {
            button.title = "Q"
        }
        
        
        let menu = NSMenu()
        
        let menuItem1 = NSMenuItem()
        menuItem1.title = "Quick Paste"
        menuItem1.keyEquivalent = "a"
        menuItem1.action = #selector(self.setQuickPaste(menuItem:))
        menuItem1.state = acceptQuickPaste == true ? .on : .off
        menu.addItem(menuItem1)
        
        let menuItem2 = NSMenuItem()
        menuItem2.title = acceptQuickPaste == true ?
            "コピーすると自動で置き換えます" : "素早く2回コピーすると置き換えます"
        menu.addItem(menuItem2)
        
        menu.addItem(NSMenuItem.separator())
        
        // サブメニューを持つNSMenuItemを作成する
        let defaultWidthMenuItem = NSMenuItem(title: "デフォルト幅", action: nil, keyEquivalent: "")
        let menuForWidth = NSMenu()
        menuForWidth.addItem(NSMenuItem(title: "空白",
                                         action: #selector(AppDelegate.setDefaultWidth(menuItem:)),
                                         keyEquivalent: ""))
        menuForWidth.addItem(NSMenuItem(title: "80%",
                                         action: #selector(AppDelegate.setDefaultWidth(menuItem:)),
                                         keyEquivalent: ""))
        menuForWidth.addItem(NSMenuItem(title: "60%",
                                         action: #selector(AppDelegate.setDefaultWidth(menuItem:)),
                                         keyEquivalent: ""))
        menuForWidth.addItem(NSMenuItem(title: "40%",
                                         action: #selector(AppDelegate.setDefaultWidth(menuItem:)),
                                         keyEquivalent: ""))
        menuForWidth.addItem(NSMenuItem(title: "20%",
                                         action: #selector(AppDelegate.setDefaultWidth(menuItem:)),
                                         keyEquivalent: ""))
        menuForWidth.addItem(NSMenuItem(title: "600",
                                         action: #selector(AppDelegate.setDefaultWidth(menuItem:)),
                                         keyEquivalent: ""))
        menuForWidth.addItem(NSMenuItem(title: "500",
                                         action: #selector(AppDelegate.setDefaultWidth(menuItem:)),
                                         keyEquivalent: ""))
        menuForWidth.addItem(NSMenuItem(title: "400",
                                         action: #selector(AppDelegate.setDefaultWidth(menuItem:)),
                                         keyEquivalent: ""))
        menuForWidth.addItem(NSMenuItem(title: "300",
                                         action: #selector(AppDelegate.setDefaultWidth(menuItem:)),
                                         keyEquivalent: ""))
        defaultWidthMenuItem.submenu = menuForWidth
        
        if defaultWithString == ""{
            menuForWidth.items[0].state = .on
        }
        for item in menuForWidth.items {
            if self.defaultWithString == item.title {item.state = .on}
        }
        
        

        menu.addItem(defaultWidthMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(NSMenuItem(title: "終了",
                                action: #selector(NSApplication.terminate(_:)),
                                keyEquivalent: "q"))
        
        statusItem.menu = menu
        
    }
    
    @objc func setQuickPaste(menuItem: NSMenuItem) {
        let userDefaults = UserDefaults.standard
        acceptQuickPaste.toggle()
        
        if acceptQuickPaste == true{
            menuItem.state = .on
            userDefaults.setValue(true, forKey: "QuickPaste")
            menuItem.menu?.items[1].title = "コピーすると自動で置き換えます"
        }else{
            menuItem.state = .off
            userDefaults.setValue(false, forKey: "QuickPaste")
            menuItem.menu?.items[1].title = "素早く2回コピーすると置き換えます"
        }
        
        userDefaults.synchronize()
    }
    
    @objc func setDefaultWidth(menuItem: NSMenuItem) {
        for item in menuItem.menu!.items {
            item.state = .off
        }
        
        if menuItem.title == "空白"{
            defaultWithString = ""
        }else{
            defaultWithString = menuItem.title
        }
        menuItem.state = .on
        
        
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(defaultWithString, forKey: "DefaultWidth")
    }
    
    @objc func onPasteboardChanged(_ notification: Notification) {
        if countIgnorPasteboardMessage == NSPasteboard.general.changeCount {
            print("Ignor pasteboard message")
            return
        }
        
        
        guard let pb = notification.object as? NSPasteboard else { return }
        guard let items = pb.pasteboardItems else { return }
        guard let item = items.first?.string(forType: .string) else { return }
        
        
        print("change count: \(   NSPasteboard.general.changeCount)")
        
        
        // 前後の文字複数行対応
        // let pattern = "([\\s\\S]*)!\\[(.*)\\]\\((https.*)\\)([\\s\\S]*)"
        
        let pattern = "!\\[(.*)\\]\\((https.*)\\)"
        guard let regex = try? NSRegularExpression(pattern: pattern,
                                                   options: NSRegularExpression.Options()) else {
            return
        }
        
        guard let matched = regex.firstMatch(in: item,
                                             range: NSRange(location: 0, length: item.count)) else {
            return
        }
        
        if matched.numberOfRanges == 3 {
            let fileName = NSString(string: item).substring(with: matched.range(at: 1))
            let urlString = NSString(string: item).substring(with: matched.range(at: 2))
            let imgString = "<img width=\"\(defaultWithString)\" src=\"\(urlString)\" alt=\"\(fileName)\">"
            
            
            NSPasteboard.general.clearContents()
            countIgnorPasteboardMessage = NSPasteboard.general.changeCount
            NSPasteboard.general.setString(imgString, forType: .string)
            
            print("replaced pasteboard")
            
            
            // acceptQuickPaste onであればpasteも行う
            if acceptQuickPaste == true{
                // Paste : Command + V
                keyDown(key: 0x09, with: CGEventFlags.maskCommand)
                keyUp(key: 0x09, with: CGEventFlags.maskCommand)
            }else{
                if canAcceptAction == true{
                    // 受付時間中に2回目のコピーがあった場合の処理
                    
                    // Paste : Command + V
                    keyDown(key: 0x09, with: CGEventFlags.maskCommand)
                    keyUp(key: 0x09, with: CGEventFlags.maskCommand)
                }
            }
            
            // menuItem光らせる
            flash()
            
        }
        
        
        
        
    }
    
    func keyDown(key: CGKeyCode, with: CGEventFlags) {
        let source = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
        let event = CGEvent(keyboardEventSource: source, virtualKey: key, keyDown: true)
        event?.flags = with
        event?.post(tap: CGEventTapLocation.cghidEventTap)
    }
    
    func keyUp(key: CGKeyCode, with: CGEventFlags) {
        let source = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
        let event = CGEvent(keyboardEventSource: source, virtualKey: key, keyDown: false)
        event?.flags = with
        event?.post(tap: CGEventTapLocation.cghidEventTap)
    }
    
    
    func flash(){
        flashCount = 0
        
        if let t = timerFlash{
            t.invalidate()
            
        }
        
        canAcceptAction = true
        
        timerFlash = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true, block: { (t) in
            if self.flashCount == 10{
                self.statusItem.button?.isHighlighted = false
                self.canAcceptAction = false
                t.invalidate()
            }else{
                self.statusItem.button?.isHighlighted.toggle()
                self.flashCount += 1
            }
        })
    }
    
    
    @objc func didProgresse() {
        statusItem.button?.isHighlighted.toggle()
    }
    
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        timer.invalidate()
    }
    
    
}


extension NSNotification.Name {
    public static let pasteboardDidChange: NSNotification.Name =
        .init(rawValue: "pasteboardDidChangeNotification")
}


func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
        let output = items.map { "\($0)" }.joined(separator: separator)
        Swift.print(output, terminator: terminator)
    #endif
}
