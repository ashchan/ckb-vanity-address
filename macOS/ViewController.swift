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


    @objc var addressSuffix = ""

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func generateButtonClicked(_ sender: Any) {
        beforeGenerate()
        DispatchQueue.global().async {
            let result = self.generate()
            DispatchQueue.main.async {
                self.process(result: result)
                self.afterGenerate()
            }
        }
    }

    func process(result: Result<Address, Error>) {
        switch result {
        case .success(let address):
            privateKeyField.stringValue = "0x" + address.privateKey
            publicKeyField.stringValue = "0x" + address.publicKey
            addressField.stringValue = address.address
        case .failure(let error):
            showError(error)
        }
    }

    func beforeGenerate() {
        view.window?.makeFirstResponder(nil)

        indicator.isHidden = false
        indicator.startAnimation(nil)
        suffixTextField.isEnabled = false
        generateButton.isEnabled = false
    }

    func afterGenerate() {
        indicator.isHidden = true
        indicator.stopAnimation(nil)
        suffixTextField.isEnabled = true
        generateButton.isEnabled = true
    }
}

extension ViewController {
    func generate() -> Result<Address, Error> {
        let generator = VanityAddressGenerator(suffix: addressSuffix)
        do {
            let address = try generator.run()
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
