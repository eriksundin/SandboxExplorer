//
//  ViewController.swift
//  SandboxExplorer
//
//  Created by Erik Sundin on 07/10/2017.
//  Copyright (c) 2017 Erik Sundin. All rights reserved.
//

import UIKit
import SandboxExplorer

class ViewController: UIViewController {

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            SandboxExplorer.shared.toggleVisibility()
        }
    }

    @IBAction func writeSomething(_ sender: UIButton) {

        var dirs = [String]()
        dirs.append(NSTemporaryDirectory())

        let paths: [FileManager.SearchPathDirectory] = [.documentDirectory, .cachesDirectory, .applicationSupportDirectory]
        for type in paths {
            if let path = NSSearchPathForDirectoriesInDomains(type, .userDomainMask, true).first {
                dirs.append(path)
            }
        }

        let fileName = "user-\(NSDate.timeIntervalSinceReferenceDate).file"
        let dirIndex = Int(arc4random_uniform(UInt32(dirs.count)))
        let path = dirs[dirIndex] + "/" + fileName

        let data = "This is some user generated content.".data(using: .utf8)
        try? data?.write(to: URL(fileURLWithPath: path))
    }

}

