import Foundation
import VanityAddress

guard CommandLine.arguments.count == 2 else {
    print("Error: Specify the suffix (1-4 char) you wish to have.")
    exit(1)
}

print(".")

let progressReport: () -> Void = {
    let indicators = [ ".", " .", "  .", " ."]
    let indicatorIndex = Int(Date().timeIntervalSince1970 * 2) % indicators.count
    print("\u{1B}[1A\u{1B}[KGenerating: \(indicators[indicatorIndex])")
}

let generator = VanityAddressGenerator(suffix: CommandLine.arguments[1])

do {
    let result = try generator.run(progressReport)
    print("🎉 Congrats! You've got an awesome address!")
    print(result)
} catch {
    print("Error: \(error.localizedDescription)")
}
