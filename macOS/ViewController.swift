//
//  ViewController.swift
//  CKB Vanity Address
//
//  Created by James Chen on 2019/06/01.
//  Copyright © 2019 James Chen. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet private weak var suffixTextField: NSTextField!
    @IBOutlet private weak var generateButton: NSButton!
    @IBOutlet private weak var indicator: NSProgressIndicator!

    @IBOutlet weak var privateKeyField: NSSecureTextField!
    @IBOutlet weak var publicKeyField: NSTextField!
    @IBOutlet weak var addressField: NSTextField!

    @IBOutlet weak var copyPrivateKeyButton: NSButton!
    @IBOutlet weak var copyPublicKeyButton: NSButton!
    @IBOutlet weak var copyAddressButton: NSButton!
    @IBOutlet weak var copyJSONButton: NSButton!

    private var generator: VanityAddressGenerator?

    private var copyButtons: [NSButton] {
        return [copyPrivateKeyButton, copyPublicKeyButton, copyAddressButton, copyJSONButton]
    }

    @objc var addressSuffix = ""
    private var address: Address! {
        didSet {
            privateKeyField.stringValue = "0x" + address.privateKey
            publicKeyField.stringValue = "0x" + address.publicKey
            addressField.stringValue = address.address
        }
    }

    @IBAction func generateButtonClicked(_ sender: Any) {
        if let generator = generator {
            generator.cancelled = true
            self.generator = nil
            enableControls()
            return
        }

        self.generator = VanityAddressGenerator(suffix: addressSuffix)

        disableControls()
        DispatchQueue.global().async {
            let result = self.generate()
            DispatchQueue.main.async {
                self.process(result: result)
                self.enableControls()
            }
        }
    }

    func process(result: Result<Address, Error>) {
        generator = nil

        switch result {
        case .success(let address):
            self.address = address
        case .failure(let error):
            guard case VanityAddressGenerator.Error.userCancelled = error else {
                return showError(error)
            }
        }
    }

    func disableControls() {
        view.window?.makeFirstResponder(nil)

        indicator.isHidden = false
        indicator.startAnimation(nil)
        suffixTextField.isEnabled = false
        generateButton.title = "Cancel"

        copyButtons.forEach { $0.isEnabled = false }
    }

    func enableControls() {
        indicator.isHidden = true
        indicator.stopAnimation(nil)
        suffixTextField.isEnabled = true
        generateButton.title = "Generate"

        copyButtons.forEach { $0.isEnabled = true }
    }

    @IBAction func copyPrivateKey(_ sender: Any) {
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(address.privateKey, forType: .string)
    }

    @IBAction func copyPublicKey(_ sender: Any) {
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(address.publicKey, forType: .string)
    }

    @IBAction func copyAddress(_ sender: Any) {
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(address.address, forType: .string)
    }

    @IBAction func copyJSON(_ sender: Any) {
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(address.description, forType: .string)
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "lockScriptViewer" {
            let lockScriptViewController = segue.destinationController as! LockScriptViewController
            lockScriptViewController.publicKey = "0x" + (address?.publicKey ?? "")
        }
    }
}

extension ViewController {
    func generate() -> Result<Address, Error> {
        do {
            let address = try generator!.run()
            return .success(address)
        } catch {
            return .failure(error)
        }
    }
}

extension ViewController {
    func showError(_ error: Error) {
        let alert = NSAlert()
        alert.messageText = error.localizedDescription
        alert.addButton(withTitle: "OK")
        alert.alertStyle = .warning

        alert.beginSheetModal(for: view.window!, completionHandler: { (modalResponse: NSApplication.ModalResponse) -> Void in
        })
    }
}
