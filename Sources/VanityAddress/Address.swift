import CKB

public struct Address: CustomStringConvertible {
    public let privateKey: String
    public let publicKey: String
    public let address: String

    init(privateKey: String) {
        self.privateKey = privateKey
        publicKey = Utils.privateToPublic(privateKey)
        address = Utils.publicToAddress(publicKey, network: .testnet)
    }

    func hasSuffix(_ suffix: String) -> Bool {
        return address.hasSuffix(suffix)
    }

    public var description: String {
        return """
        {
            "private_key": "0x\(privateKey)",
            "public_key": "0x\(publicKey)",
            "address": "\(address)"
        }
        """
    }
}
