# CKB Vanity Address Generator

Generate a CKB address with specified suffix.

## Requirements

Swift 5, Swift Package Manager, and fun.

### macOS

```shell
brew install pkg-config
brew install libsodium
```

### Linux (Ubuntu)

~It should be easy to support Linux, but I have to see if I'm not that lazy to do so anytime soon.~

Update: supported, but it's a stupid implementation calling `/usr/bin/openssl` to generate private keys (expect it to be slower).
Please figure out how to set up Swift first.

```shell
apt install libsodium-dev
```

## Usage

```swift
swift build
// Replace `.build/x86_64-apple-macosx/debug/` with the actual build path on your machine.
// 666 is the suffix to look for.
.build/x86_64-apple-macosx/debug/cva 666
```

Output:

```shell
Working:  .
🎉 Congrats! You've got an awesome address!
	Private key: 5d253b5d5db6ce895fc3117bf8e4c90a52b67a105efc594e5e481393d0479b9c
	Public key: 0397e4dc99ffc905ecd9f6f7d29cd88e42f3791ffabada275aa12df5e708b34100
	Address: ckt1q9gry5zg65wssxnvredy0cm9puhkafz8py7c8yhvhlr666
```

## Warning

[CKB address format](https://github.com/nervosnetwork/rfcs/blob/c1edeeefdc0768c024e6a9f035bc5b099f61ccbb/rfcs/0000-address-format/0000-address-format.md) wraps lock script with Bech32 encoding. All addresses always have the same first 7-9 characters, thus generating addresses with a prefix you wish to own doesn't make much sense.

This tool generates address with a **suffix** you specify. Practically it should be very easy and fast to generate addresses with a 1-3 character suffix. For longer suffix it might take quite long long long time to finish, due to the fact this is a silly single thread brute force program.

[Bech32](https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki#bech32) doesn't allow a few alphanumeric characters. Trying to specify "1", "b", "i", or "o" will not work.

## License

This is released under the [MIT License](LICENSE).
