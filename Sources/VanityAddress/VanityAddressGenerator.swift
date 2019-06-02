import Foundation

public final class VanityAddressGenerator {
    private let suffix: String
    var cancelled = false

    public init(suffix: String = "") {
        self.suffix = suffix
    }

    public func run(_ progressReport: (() -> Void)? = nil) throws -> Address {
        guard isSuffixValid else {
            throw Error.invalidCharacter
        }

        var address: Address
        repeat {
            progressReport?()
            address = nextAddress()
            if cancelled {
                throw Error.userCancelled
            }
        } while !address.hasSuffix(suffix)

        return address
    }
}

private extension VanityAddressGenerator {
    func nextAddress() -> Address {
        return Address(privateKey: randomPrivateKey())
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
        case invalidCharacter
        case userCancelled

        public var errorDescription: String? {
            switch self {
            case .invalidCharacter:
                return "Invalid character within suffix. Only Bech32 characters are allowed."
            case .userCancelled :
                return "Sorry you deciced to go."
            }
        }
    }
}
