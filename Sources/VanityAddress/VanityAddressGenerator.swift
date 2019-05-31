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

        print(".")

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
        #if os(Linux)
        return randomPrivateKeyLinux()
        #else // if os(macOS)
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
        #endif
    }

    // This is for Linux only, just mark it as 10.13 to silent the build warnings.
    // And don't be serious - I don't know how to generate a proper pk on Linux.
    @available(OSX 10.13, *)
    func randomPrivateKeyLinux() -> String {
        let openssl = Process()
        openssl.executableURL = URL(fileURLWithPath: "/usr/bin/openssl") // Yes it's hard-coded ;(
        openssl.arguments = ["rand", "-hex", "32"]

        let pipe = Pipe()
        openssl.standardOutput = pipe
        openssl.standardError = pipe
        try! openssl.run()
        openssl.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let key = String(data: data, encoding: .utf8) ?? ""
        return String(key.dropLast()) // \n
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
