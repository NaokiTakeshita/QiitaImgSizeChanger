//
//  ViewController.swift
//  qiitaImgSizeChanger
//
//  Created by Naoki Takeshita on 2021/05/13.
//

import Cocoa

class ViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onPasteboardChanged),
                                               name: .pasteboardDidChange,
                                               object: nil)
        
    }
    
    @objc func onPasteboardChanged(_ notification: Notification) {
        guard let pb = notification.object as? NSPasteboard else { return }
        guard let items = pb.pasteboardItems else { return }
        guard let item = items.first?.string(forType: .string) else { return }
        
      //  print("New item in pasteboard: '\(item)'")
        
        let pattern = "!\\[(.*)\\]\\((https.*)\\)"
        guard let regex = try? NSRegularExpression(pattern: pattern,
                                                  options: NSRegularExpression.Options()) else {
            return
        }
        
//        let results = regex.matches(in: item, options: [], range: NSRange(0..<item.count))
//        if results.count == 0 {
//            print("ヒットなし")
//            return
//        }
        
        guard let matched = regex.firstMatch(in: item,
                                             range: NSRange(location: 0, length: item.count)) else {
            return
        }

       // print("\(results.count)件ヒット")
//        print(results)
    
      //  print(matched)
        
//        print(matched.numberOfRanges)
//         (0 ..< matched.numberOfRanges).map {
//            print( NSString(string: item).substring(with: matched.range(at: $0)))
//         }
    
        if matched.numberOfRanges == 3 {
            let urlString = NSString(string: item).substring(with: matched.range(at: 2))
            let imgString = "<img src=\"\(urlString)\" width=\"60%\">"
            print("<img src=\"\(urlString)\" width=\"60%\">")
            print(NSPasteboard.general.clearContents())
            print(NSPasteboard.general.setString(imgString, forType: .string))
        }
        
        
        
//        let matched = regex.firstMatch(in: self, range: NSRange(location: 0, length: self.count))
//           else { return [] }
//           return (0 ..< matched.numberOfRanges).map {
//               NSString(string: self).substring(with: matched.range(at: $0))
//           }
        
   //     print("match")
        
        
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
}

