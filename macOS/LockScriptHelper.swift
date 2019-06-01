//
//  LockScriptHelper.swift
//  CKB Vanity Address
//
//  Created by James Chen on 2019/06/01.
//  Copyright © 2019 James Chen. All rights reserved.
//

import Foundation
import CKB

final class LockScriptHelper {
    private let publicKey: String
    static var systemScript: SystemScript?

    static func loadSystemScript() throws -> SystemScript {
        if let systemScript = systemScript {
            return systemScript
        }

        let nodeUrl = URL(string: "http://localhost:8114")!
        let script = try SystemScript.loadFromGenesisBlock(nodeUrl: nodeUrl)
        systemScript = script
        return script
    }

    init(publicKey: String) {
        self.publicKey = publicKey
    }

    func getLockScript() throws -> Script {
        let pubkeyHash = Utils.prefixHex(
            AddressGenerator(network: .testnet).hash(for: Data(hex: publicKey)).toHexString()
        )
        return Script(args: [pubkeyHash], codeHash: try LockScriptHelper.loadSystemScript().codeHash)
    }
}
