import Foundation
import CKB

public final class VanityAddressGenerator {
    private let arguments: [String]
    private var suffix = ""

    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }

    public func run() throws {
        guard arguments.count == 2 else {
             throw Error.suffixNotSpecified
        }

        suffix = arguments[1]
        guard isSuffixValid else {
            throw Error.invalidCharacter
        }

        var privateKey = ""
        var publicKey = ""
        var address = ""
        while !address.hasSuffix(suffix) {
            printIndicator()

            (privateKey, publicKey, address) = nextAddress()
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
            guard let key = SecKeyCreateRandomKey(attributes as CFDictionary, nil),
                let privateKey = SecKeyCopyExternalRepresentation(key, nil) as Data? else {
                return ""
            }
            return privateKey.suffix(32).toHexString()
        } else {
            return ""
        }
    }
}

public extension VanityAddressGenerator {
    var isSuffixValid: Bool {
        let characters = "qpzry9x8gf2tvdw0s3jn54khce6mua7l".map(String.init)
        for char in suffix.map(String.init) {
            if !characters.contains(char) {
                return false
            }
        }

        return true
    }

    enum Error: Swift.Error, LocalizedError {
        case suffixNotSpecified
        case invalidCharacter

        public var errorDescription: String? {
            switch self {
            case .suffixNotSpecified:
                return "Specify the suffix (1-4 char) you wish to have."
            case .invalidCharacter:
                return "Invalid character within suffix. Only Bech32 characters are allowed."
            }
        }
    }
}
