# CKB Vanity Address Generator

Generate a CKB address with specified suffix.

## Requirements

Swift 5, Swift Package Manager, and fun.

```shell
brew install pkg-config
brew install libsodium
```

It should be easy to support Linux, but I have to see if I'm not that lazy to do so anytime soon.

## Usage

```swift
swift package update
swift build
// Replace `.build/x86_64-apple-macosx/debug/` with the actual build path on your machine.
// 666 is the suffix to look for.
.build/x86_64-apple-macosx/debug/ckb-vanity-address 666
```

## Warning

[CKB address format](https://github.com/nervosnetwork/rfcs/blob/c1edeeefdc0768c024e6a9f035bc5b099f61ccbb/rfcs/0000-address-format/0000-address-format.md) wraps lock script with Bech32 encoding. All addresses always have the same first 7-9 characters, thus generating addresses with a prefix you wish to own doesn't make much sense.

This tool generates address with a **suffix** you specify. Practically it should be very easy and fast to generate addresses with a 1-3 character suffix. For longer suffix it might take quite long long long time to finish, due to the fact this is a silly single thread brute force program.

[Bech32](https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki#bech32) doesn't allow a few alphanumeric characters. Trying to specify "1", "b", "i", or "o" will not work.

## License

This is released under the [MIT License](LICENSE).