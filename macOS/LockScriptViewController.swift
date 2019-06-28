//
//  LockScriptViewController.swift
//  CKB Vanity Address
//
//  Created by James Chen on 2019/06/01.
//  Copyright © 2019 James Chen. All rights reserved.
//

import Cocoa

class LockScriptViewController: NSViewController {
    @objc var publicKey: String = ""
    @IBOutlet weak var lockScriptField: NSTextField!
    @IBOutlet weak var copyLockScriptButton: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        copyLockScriptButton.isEnabled = false
    }

    @IBAction func getLockScript(_ sender: Any) {
        view.window?.makeFirstResponder(nil)

        let helper = LockScriptHelper(publicKey: publicKey)
        do {
            let lockScript = try helper.getLockScript()
            lockScriptField.stringValue = lockScript.param.description
            copyLockScriptButton.isEnabled = true
        } catch {
            lockScriptField.stringValue = "Make sure local CKB node is running and RPC exposes from http://localhost:8114"
            copyLockScriptButton.isEnabled = false
        }
    }

    @IBAction func copyLockScript(_ sender: Any) {
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(lockScriptField.stringValue, forType: .string)
    }
}
