import Foundation
import CKB

public final class VanityAddressGenerator {
    private let arguments: [String]

    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }

    public func run() throws {
        guard arguments.count == 2 else {
             throw Error.suffixNotSpecified
        }

        let suffix = arguments[1]
        print("Now I need a secret to hide away for `\(suffix)`")
        
        // TODO: More check, e.g., suffix should only contain characters that Bech32 allows.

        var privateKey = ""
        var publicKey = ""
        var address = ""
        var found = false
        while !found {
            printIndicator()

            (privateKey, publicKey, address) = nextAddress()
            found = address.hasSuffix(suffix)
        }

        print(
            """
            🎉 Congrats! You've got an awesome address!
            \tPrivate key: \(privateKey)
            \tPublic key: \(publicKey)
            \tAddress: \(address)
            """
        )
    }
}

private extension VanityAddressGenerator {
    var indicators: [String] {
        return [ ".", " .", "  .", " ."]
    }

    func printIndicator() {
        let indicatorIndex = Int(Date().timeIntervalSince1970 * 2) % indicators.count
        let indicator = indicators[indicatorIndex]
        print("\u{1B}[1A\u{1B}[KWorking: \(indicator)")
    }
}

private extension VanityAddressGenerator {
    func nextAddress() -> (privateKey: String, publicKey: String, address: String) {
        let privateKey = randomPrivateKey()
        let publicKey = Utils.privateToPublic(privateKey)
        return (privateKey, publicKey, Utils.publicToAddress(publicKey, network: .testnet))
    }

    func randomPrivateKey() -> String {
        if #available(OSX 10.12, *) {
            let attributes: [String: Any] = [
                kSecAttrKeyType as String: kSecAttrKeyTypeEC,
                kSecAttrKeySizeInBits as String: 256,
                kSecPrivateKeyAttrs as String: [kSecAttrIsExtractable as String: true]
            ]
            guard let key = SecKeyCreateRandomKey(attributes as CFDictionary, nil) else {
                return ""
            }
            guard let privateKey = SecKeyCopyExternalRepresentation(key, nil) as Data? else {
                return ""
            }
            return privateKey.suffix(32).toHexString()
        } else {
            return ""
        }
    }
}

public extension VanityAddressGenerator {
    enum Error: Swift.Error, LocalizedError {
        case suffixNotSpecified

        public var errorDescription: String? {
            switch self {
            case .suffixNotSpecified:
                return "Specify the suffix (1-4 char) you wish to have."
            }
        }
    }
}
